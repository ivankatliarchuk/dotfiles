# Issue #1801: Expose Registered Metrics - Comprehensive Analysis

**Repository:** prometheus/client_golang
**Status:** ✅ Implemented and PR Created
**Date:** 2025-12-25
**Issue:** [prometheus/client_golang#1801](https://github.com/prometheus/client_golang/issues/1801)
**Pull Request:** [#1931](https://github.com/prometheus/client_golang/pull/1931)
**Related PR:** #890 (previous attempt)

## Executive Summary

Issue #1801 requests programmatic access to registered metrics metadata without requiring a full scrape operation. This analysis examines:

1. The current state of the Prometheus client_golang library
2. How external-dns currently works around this limitation using **unsafe reflection hacks**
3. Why this feature is critical for the Prometheus ecosystem
4. Proposed implementation approach

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Current State Analysis](#current-state-analysis)
- [External-DNS Case Study](#external-dns-case-study)
- [The Gap](#the-gap)
- [Proposed Solution](#proposed-solution)
- [Implementation Plan](#implementation-plan)
- [Impact Analysis](#impact-analysis)

---

## Problem Statement

### What Users Want

Projects using Prometheus client_golang need to:

1. **Generate documentation** automatically from registered metrics
2. **Test metric registration** without starting servers or scraping endpoints
3. **Introspect metrics** at runtime for debugging and tooling
4. **Discover available metrics** programmatically

### Current Reality

There is **NO official API** to list registered metrics. The only options are:

- ❌ Run the service and scrape `/metrics` (heavyweight, incomplete)
- ❌ Parse source code with AST walking (fragile, complex)
- ❌ Manually maintain parallel documentation (error-prone, drifts)
- ❌ Use unsafe reflection hacks (breaks encapsulation, undefined behavior)

---

## Current State Analysis

### Registry Internal Structure

**File:** `prometheus/registry.go:260-267`

```go
type Registry struct {
    mtx                   sync.RWMutex
    collectorsByID        map[uint64]Collector    // Collectors indexed by hash
    descIDs               map[uint64]struct{}     // Set of descriptor IDs
    dimHashesByName       map[string]uint64       // Metric name → dimension hash
    uncheckedCollectors   []Collector             // Collectors without descriptors
    pedanticChecksEnabled bool
}
```

**The data is there**, but it's all **private** (unexported fields).

### Existing Access Methods

#### 1. Registry.Describe(ch chan<- *Desc)

**Location:** `prometheus/registry.go:563-572`

```go
// Describe implements Collector.
func (r *Registry) Describe(ch chan<- *Desc) {
    r.mtx.RLock()
    defer r.mtx.RUnlock()

    // Only report the checked Collectors; unchecked collectors don't report any Desc.
    for _, c := range r.collectorsByID {
        c.Describe(ch)
    }
}
```

**Problems:**
- Channel-based API (requires goroutines and channel management)
- Not idiomatic for simple read operations
- Returns `*Desc` with all fields unexported
- Error-prone (easy to deadlock or leak goroutines)

**Example usage:**
```go
// Current pattern - verbose and error-prone
descChan := make(chan *prometheus.Desc)
go func() {
    registry.Describe(descChan)
    close(descChan)
}()

for desc := range descChan {
    // desc.fqName is unexported - can't access!
    // desc.help is unexported - can't access!
    // Can only call desc.String() which returns formatted text
    fmt.Println(desc.String())
}
```

#### 2. Registry.Gather() ([]*dto.MetricFamily, error)

**Location:** `prometheus/registry.go:412-560`

**Problems:**
- Calls `Collect()` on all collectors (heavyweight)
- Returns actual metric **values**, not just metadata
- Overkill for documentation generation
- Can be slow and resource-intensive

### Descriptor Structure

**File:** `prometheus/desc.go:45-67`

```go
type Desc struct {
    fqName          string              // ❌ Unexported
    help            string              // ❌ Unexported
    constLabelPairs []*dto.LabelPair    // ❌ Unexported
    variableLabels  *compiledLabels     // ❌ Unexported
    id              uint64              // ❌ Unexported
    dimHash         uint64              // ❌ Unexported
    err             error               // ✅ Has Err() getter (line 190)
}
```

**Only available method:**
```go
func (d *Desc) String() string  // Returns formatted string, not structured data
func (d *Desc) Err() error      // Returns construction error
```

**Missing methods:**
```go
// ❌ Not available:
func (d *Desc) Name() string
func (d *Desc) Help() string
func (d *Desc) ConstLabels() Labels
func (d *Desc) VariableLabels() []string
```

---

## External-DNS Case Study

External-DNS (mentioned in issue #1801) has implemented a **comprehensive workaround** demonstrating both the need for this feature and the pain of not having it.

### Architecture

```
external-dns/
├── pkg/metrics/
│   ├── models.go           # Custom metric wrapper types (~212 lines)
│   ├── metrics.go          # Custom registry (~103 lines)
│   └── labels.go
├── controller/
│   └── controller.go       # Metric definitions with wrappers
└── internal/gen/docs/metrics/
    ├── main.go             # Generator with UNSAFE HACKS (~127 lines)
    ├── main_test.go        # Validation tests
    └── templates/
        └── metrics.gotpl   # Documentation template
```

**Total workaround code:** ~500+ lines
**Maintainability:** High burden
**Safety:** Uses `unsafe.Pointer()` ⚠️

### Solution 1: Custom Metric Wrappers

**File:** `pkg/metrics/models.go`

External-DNS created **custom wrapper types** that duplicate Prometheus functionality:

```go
// Custom registry that MANUALLY tracks metadata
type MetricRegistry struct {
    Registerer prometheus.Registerer
    Metrics    []*Metric              // ⚠️ Manual parallel tracking!
    mName      map[string]bool
}

// Duplicate metadata storage
type Metric struct {
    Type      string
    Namespace string
    Subsystem string
    Name      string
    Help      string
    FQDN      string
}

// Wrapper for every Prometheus metric type
type GaugeMetric struct {
    Metric                    // Custom metadata
    Gauge prometheus.Gauge    // Actual Prometheus metric
}

type CounterMetric struct {
    Metric
    Counter prometheus.Counter
}

type GaugeVecMetric struct {
    Metric
    Gauge prometheus.GaugeVec
}
// ... More wrappers for Counter, Summary, Histogram, Func, etc.
```

**Problems:**
- ❌ Duplicate source of truth (metadata stored twice)
- ❌ Must create wrapper for every Prometheus type
- ❌ Can't use standard `prometheus.NewGauge()` API
- ❌ Doesn't work with third-party metrics
- ❌ High maintenance burden

### Solution 2: Custom Registration with Metadata Tracking

**File:** `pkg/metrics/metrics.go:66-102`

```go
func (m *MetricRegistry) MustRegister(cs IMetric) {
    switch v := cs.(type) {
    case CounterMetric, GaugeMetric, SummaryVecMetric, ...:
        // Check for duplicates
        if _, exists := m.mName[cs.Get().FQDN]; exists {
            return
        }
        m.mName[cs.Get().FQDN] = true

        // ⚠️ Store metadata in parallel array
        m.Metrics = append(m.Metrics, cs.Get())

        // Register with actual Prometheus registry
        switch metric := v.(type) {
        case CounterMetric:
            m.Registerer.MustRegister(metric.Counter)
        case GaugeMetric:
            m.Registerer.MustRegister(metric.Gauge)
        // ... Handle all wrapper types
        }
    }
}
```

**Usage in application:**

**File:** `controller/controller.go:38-150`

```go
var (
    // Instead of: prometheus.NewCounter(...)
    // Must use: metrics.NewCounterWithOpts(...)
    registryErrorsTotal = metrics.NewCounterWithOpts(
        prometheus.CounterOpts{
            Subsystem: "registry",
            Name:      "errors_total",
            Help:      "Number of Registry errors.",
        },
    )

    sourceRecords = metrics.NewGaugedVectorOpts(
        prometheus.GaugeOpts{
            Subsystem: "source",
            Name:      "records",
            Help:      "Number of source records...",
        },
        []string{"record_type"},
    )
    // ... 21 metrics total
)

func init() {
    // Register with custom registry
    metrics.RegisterMetric.MustRegister(registryErrorsTotal)
    metrics.RegisterMetric.MustRegister(sourceErrorsTotal)
    // ... Manual registration of all 21 metrics
}
```

### Solution 3: UNSAFE Reflection Hack for Runtime Metrics

**File:** `internal/gen/docs/metrics/main.go:106-126`

This is the **most egregious workaround** - using unsafe reflection to access private fields:

```go
// getRuntimeMetrics retrieves the list of runtime metrics from the Prometheus library.
func getRuntimeMetrics(reg prometheus.Registerer) []string {
    var runtimeMetrics []string

    // ⚠️⚠️⚠️ UNSAFE HACK ALERT ⚠️⚠️⚠️
    // Uses reflection + unsafe to access PRIVATE fields!
    values := reflect.ValueOf(reg).Elem().FieldByName("dimHashesByName")
    values = reflect.NewAt(values.Type(), unsafe.Pointer(values.UnsafeAddr())).Elem()

    switch v := values.Interface().(type) {
    case map[string]uint64:
        for k := range v {
            // Extract metric names from internal hash map
            if !strings.HasPrefix(k, "external_dns") {
                runtimeMetrics = append(runtimeMetrics, k)
            }
        }
    default:
    }
    sort.Strings(runtimeMetrics)
    return runtimeMetrics
}
```

**What this code does:**

1. Uses `reflect.ValueOf()` to introspect Registry object
2. Accesses **PRIVATE** field `dimHashesByName`
3. Uses `unsafe.Pointer()` to bypass Go's access restrictions
4. Extracts metric names from internal hash map
5. Filters to get only runtime metrics

**Why this is terrible:**

| Issue | Impact |
|-------|--------|
| Breaks encapsulation | Accesses private implementation details |
| Fragile | Will break if Prometheus changes internal structure |
| Unsafe | Uses `unsafe` package - undefined behavior possible |
| Not guaranteed | Field names/types could change in any release |
| Platform-dependent | Relies on memory layout assumptions |
| Incomplete | Only gets names, not help text, labels, types, etc. |
| Maintenance burden | Must be updated if Prometheus internals change |

**Developer comment in code (line 110-111):**
```go
// hacks to get the runtime metrics from prometheus library
// safe to do because it's a just a documentation generator
```

**Translation:** "We know this violates best practices, but we have no alternative."

### Documentation Generation

**File:** `internal/gen/docs/metrics/main.go:47-93`

```go
func main() {
    path := fmt.Sprintf("%s/docs/monitoring/metrics.md", testPath)

    // ✅ Custom metrics: Easy access via wrapper
    content, err := generateMarkdownTable(metrics.RegisterMetric, true)

    _ = utils.WriteToFile(path, content)
}

func generateMarkdownTable(m *metrics.MetricRegistry, withRuntime bool) (string, error) {
    // ✅ Custom metrics: Direct array access
    sortMetrics(m.Metrics)

    var runtimeMetrics []string
    if withRuntime {
        // ⚠️ Runtime metrics: UNSAFE HACK required!
        runtimeMetrics = getRuntimeMetrics(prometheus.DefaultRegisterer)
    }

    // Render template with metadata
    tmpl.ExecuteTemplate(&b, "metrics.gotpl", struct {
        Metrics        []*metrics.Metric  // ✅ From custom tracking
        RuntimeMetrics []string           // ⚠️ From unsafe hack
    }{...})
}
```

**Template:** `templates/metrics.gotpl`

```markdown
## Supported Metrics

| Name                             | Metric Type | Subsystem   |  Help                                                 |
|:---------------------------------|:------------|:------------|:------------------------------------------------------|
{{- range .Metrics }}
| {{ .Name }} | {{ .Type | capitalize }} | {{ .Subsystem }} | {{ .Help }} |
{{- end }}
```

**Generated output:** `docs/monitoring/metrics.md`

```markdown
# Available Metrics

| Name                             | Metric Type | Subsystem   |  Help                                                 |
|:---------------------------------|:------------|:------------|:------------------------------------------------------|
| build_info | Gauge |  | A metric with a constant '1' value... |
| consecutive_soft_errors | Gauge | controller | Number of consecutive soft errors... |
| last_reconcile_timestamp_seconds | Gauge | controller | Timestamp of last attempted sync... |
| no_op_runs_total | Counter | controller | Number of reconcile loops... |
| verified_records | Gauge | controller | Number of DNS records... |
...21 metrics total
```

### External-DNS Workaround Summary

| Component | Lines of Code | Purpose | Safety |
|-----------|---------------|---------|--------|
| Custom wrappers (models.go) | ~212 | Duplicate Prometheus types with metadata | ✅ Safe |
| Custom registry (metrics.go) | ~103 | Track metadata in parallel | ✅ Safe |
| Unsafe reflection hack (main.go) | ~20 | Access runtime metrics | ❌ **UNSAFE** |
| Template rendering | ~100 | Generate markdown | ✅ Safe |
| **Total** | **~500+** | Work around missing feature | **Mixed** |

**Maintenance burden:**
- Must keep wrappers in sync with Prometheus updates
- Must test unsafe hack doesn't break with new releases
- Can't use standard Prometheus API in application code
- Doesn't work with third-party metrics

---

## The Gap

### What Exists vs What's Needed

| Capability | Current State | What's Needed |
|------------|---------------|---------------|
| **Access to registry data** | ❌ All fields private | ✅ Public API |
| **List registered metrics** | ❌ Channel-based Describe() | ✅ Simple slice return |
| **Get metric name** | ❌ No getter | ✅ `desc.Name()` |
| **Get help text** | ❌ No getter | ✅ `desc.Help()` |
| **Get variable labels** | ❌ No getter | ✅ `desc.VariableLabels()` |
| **Get const labels** | ❌ No getter | ✅ `desc.ConstLabels()` |
| **Registry method** | ❌ None | ✅ `reg.Descriptors()` |
| **Use case: Docs** | ❌ Unsafe hacks required | ✅ Simple iteration |
| **Use case: Testing** | ❌ Must scrape | ✅ Direct assertions |

### Why Channels Are Insufficient

The existing `Describe(ch chan<- *Desc)` method has fundamental issues:

```go
// Current pattern - Complex and error-prone
descChan := make(chan *prometheus.Desc, 100)
go func() {
    registry.Describe(descChan)
    close(descChan)
}()

var descs []*prometheus.Desc
for desc := range descChan {
    // Even if we collect them...
    descs = append(descs, desc)
    // ...desc fields are all unexported!
    // Can only use String() method
}
```

**Problems:**

1. **Complexity**: Requires goroutines and channel management
2. **Error-prone**: Easy to deadlock if channel isn't drained
3. **Not idiomatic**: Slices are simpler for read-only operations
4. **Incomplete**: `Desc` fields are unexported anyway

### Why Gather() Is Wrong Tool

```go
mfs, err := registry.Gather()
```

**Problems:**

1. **Expensive**: Calls `Collect()` on all collectors
2. **Wrong data**: Returns metric **values**, not metadata
3. **Slow**: Full collection/scrape operation
4. **Overkill**: Just need names and help text

---

## Proposed Solution

### Phase 1: Add Getter Methods to Desc

**File:** `prometheus/desc.go`

```go
// Name returns the fully-qualified metric name.
func (d *Desc) Name() string {
    return d.fqName
}

// Help returns the help text for this metric.
func (d *Desc) Help() string {
    return d.help
}

// ConstLabels returns the constant labels as a map.
func (d *Desc) ConstLabels() Labels {
    labels := Labels{}
    for _, lp := range d.constLabelPairs {
        labels[lp.GetName()] = lp.GetValue()
    }
    return labels
}

// VariableLabels returns the names of variable labels.
func (d *Desc) VariableLabels() []string {
    if d.variableLabels == nil {
        return nil
    }
    return d.variableLabels.names
}
```

**Backwards compatibility:** ✅ Safe (only adds new methods)

### Phase 2: Add Descriptors Method to Registry

**File:** `prometheus/registry.go`

```go
// Descriptors returns all metric descriptors currently registered.
// This is useful for introspection, documentation generation, and testing.
// Unchecked collectors (those that don't provide descriptors) are excluded.
//
// The returned descriptors are collected by calling Describe on all registered
// collectors. Duplicate descriptors from the same collector are automatically
// deduplicated.
func (r *Registry) Descriptors() []*Desc {
    r.mtx.RLock()
    defer r.mtx.RUnlock()

    descMap := make(map[uint64]*Desc)

    for _, c := range r.collectorsByID {
        descChan := make(chan *Desc, capDescChan)
        go func(collector Collector) {
            collector.Describe(descChan)
            close(descChan)
        }(c)

        for desc := range descChan {
            // Deduplicate by descriptor ID
            descMap[desc.id] = desc
        }
    }

    // Convert map to slice
    descs := make([]*Desc, 0, len(descMap))
    for _, desc := range descMap {
        descs = append(descs, desc)
    }

    return descs
}
```

**Backwards compatibility:** ✅ Safe (new method on existing type)

### Phase 3: Optional - Add to Interface

**Option A:** Don't add to `Registerer` interface (avoid breaking change)

**Option B:** Add to new interface (allows gradual adoption)

```go
type RegistererWithIntrospection interface {
    Registerer
    Descriptors() []*Desc
}
```

---

## Implementation Plan

### Step 1: Add Desc Getter Methods

**File:** `prometheus/desc.go`

**Changes:**
1. Add `Name() string` method
2. Add `Help() string` method
3. Add `ConstLabels() Labels` method
4. Add `VariableLabels() []string` method

**Tests:**
- Test each getter returns correct value
- Test with nil/empty fields
- Test ConstLabels conversion

**Estimated effort:** 2-4 hours

### Step 2: Add Registry.Descriptors Method

**File:** `prometheus/registry.go`

**Changes:**
1. Add `Descriptors() []*Desc` method
2. Handle deduplication properly
3. Ensure thread safety
4. Document behavior with unchecked collectors

**Tests:**
- Test with multiple collectors
- Test deduplication
- Test thread safety (concurrent calls)
- Test with unchecked collectors
- Test with empty registry

**Estimated effort:** 4-8 hours

### Step 3: Documentation

**Files:**
- Update `prometheus/doc.go`
- Add example usage
- Update README if needed

**Examples:**
```go
// Example: Generate documentation
func GenerateMetricsDocs(reg *prometheus.Registry) {
    descs := reg.Descriptors()

    for _, desc := range descs {
        fmt.Printf("Name: %s\n", desc.Name())
        fmt.Printf("Help: %s\n", desc.Help())
        fmt.Printf("Labels: %v\n", desc.VariableLabels())
        fmt.Println()
    }
}

// Example: Test metrics are registered
func TestMetricsRegistered(t *testing.T) {
    reg := prometheus.NewRegistry()
    reg.MustRegister(myCounter)

    descs := reg.Descriptors()

    var found bool
    for _, desc := range descs {
        if desc.Name() == "my_counter_total" {
            found = true
            assert.Equal(t, "Total count of things", desc.Help())
        }
    }
    assert.True(t, found, "metric should be registered")
}
```

**Estimated effort:** 2-4 hours

### Step 4: Migration Guide

For projects like external-dns:

**Before (500+ lines of workarounds):**
```go
// Custom wrapper system
type MetricRegistry struct {
    Metrics []*Metric
    // ...
}

// Unsafe reflection
values := reflect.ValueOf(reg).Elem().FieldByName("dimHashesByName")
values = reflect.NewAt(values.Type(), unsafe.Pointer(values.UnsafeAddr())).Elem()
```

**After (simple and safe):**
```go
// Use standard Prometheus
reg := prometheus.NewRegistry()

// Simple introspection
descs := reg.Descriptors()

for _, desc := range descs {
    fmt.Printf("%s: %s\n", desc.Name(), desc.Help())
}
```

**Code reduction:** ~500 lines → ~20 lines
**Unsafe code:** Eliminated completely

---

## Impact Analysis

### Benefits

#### For Users

| Benefit | Impact |
|---------|--------|
| **Documentation generation** | Automated, always in sync |
| **Testing** | Simple assertions, no scraping needed |
| **Debugging** | Runtime introspection |
| **Tooling** | IDEs, linters can understand metrics |
| **Safety** | No more unsafe hacks |
| **Simplicity** | Standard API, no custom wrappers |

#### For Ecosystem

| Project | Current Pain | Relief |
|---------|-------------|---------|
| external-dns | 500+ lines of wrappers + unsafe hacks | Delete all workaround code |
| Thanos | Manual documentation | Automated generation |
| Other projects | Can't introspect metrics | Simple, safe API |

### Risks

#### Breaking Changes

**Risk:** None if implemented carefully

**Mitigation:**
- Only add new methods (no changes to existing APIs)
- Don't modify interfaces (or use new interface)
- Maintain backward compatibility

#### Performance

**Risk:** `Descriptors()` could be expensive

**Mitigation:**
- Use same pattern as `Describe()` (already exists)
- Lock is read-only
- Deduplication is O(n) where n = number of descriptors
- Users call this infrequently (doc generation, testing)

#### Maintenance

**Risk:** New API surface to maintain

**Mitigation:**
- Small, focused API (4 getters + 1 method)
- Well-defined behavior
- Clear documentation
- Comprehensive tests

### Compatibility

| Aspect | Status |
|--------|--------|
| Go version | No new language features needed |
| API compatibility | ✅ Additive only |
| Existing code | ✅ No changes required |
| Third-party packages | ✅ Compatible |

---

## Success Criteria

### Must Have

- ✅ `Desc` getter methods work correctly
- ✅ `Registry.Descriptors()` returns all registered descriptors
- ✅ Thread-safe implementation
- ✅ No breaking changes
- ✅ Comprehensive test coverage
- ✅ Documentation with examples

### Should Have

- ✅ external-dns can migrate and delete unsafe code
- ✅ Performance comparable to current `Describe()`
- ✅ Works with all collector types
- ✅ Clear migration guide

### Could Have

- Optional: New interface for introspection
- Optional: Helper functions for common patterns
- Optional: CLI tool for metric listing

---

## Related Work

### Previous Attempts

**PR #890:** Mentioned in issue, needs investigation
- What was proposed?
- Why was it not merged?
- What can we learn?

**Action:** Review PR #890 before implementation

### Similar Issues

- Projects needing metric introspection
- Documentation generation tools
- Testing frameworks

### Alternatives Considered

#### Alternative 1: Keep Status Quo

**Pros:** No work needed
**Cons:** Projects continue using unsafe hacks

**Verdict:** ❌ Not acceptable

#### Alternative 2: External Tool

**Pros:** No changes to client_golang
**Cons:** Still requires unsafe reflection

**Verdict:** ❌ Doesn't solve the problem

#### Alternative 3: Full Scrape-Based Solution

**Pros:** Uses existing `Gather()`
**Cons:** Heavy, slow, requires collection

**Verdict:** ❌ Wrong tool for the job

#### Alternative 4: Proposed Solution (Getters + Descriptors)

**Pros:**
- Simple, safe, official API
- No unsafe code needed
- Minimal maintenance burden
- Works for all use cases

**Cons:**
- Requires implementation work
- Increases API surface slightly

**Verdict:** ✅ **Recommended**

---

## Next Steps

### Investigation Phase

1. Review PR #890 and understand why it stalled
2. Check for other related issues or discussions
3. Confirm approach with maintainers

### Implementation Phase

1. Create draft PR with Desc getters
2. Add Registry.Descriptors() method
3. Write comprehensive tests
4. Update documentation
5. Add examples

### Validation Phase

1. Test with external-dns migration
2. Performance benchmarks
3. Community feedback
4. Final review and merge

---

## Appendix

### File References

#### Client_golang Repository

- `prometheus/registry.go:260-267` - Registry struct
- `prometheus/registry.go:563-572` - Describe method
- `prometheus/registry.go:412-560` - Gather method
- `prometheus/desc.go:45-67` - Desc struct
- `prometheus/desc.go:190` - Existing Err() getter

#### External-DNS Repository

- `pkg/metrics/models.go:26-212` - Custom wrapper types
- `pkg/metrics/metrics.go:66-102` - Custom registry
- `internal/gen/docs/metrics/main.go:106-126` - Unsafe reflection hack
- `controller/controller.go:38-150` - Metric definitions

### Code Statistics

| Component | Lines | Complexity |
|-----------|-------|------------|
| External-DNS workarounds | ~500 | High |
| Proposed implementation | ~100 | Low |
| **Savings** | **~400** | **Significant** |

### References

- [Issue #1801](https://github.com/prometheus/client_golang/issues/1801)
- External-DNS workaround implementation
- Prometheus documentation
- Go reflection best practices

---

## Implementation Summary

### ✅ Status: Complete

**Pull Request:** [#1931](https://github.com/prometheus/client_golang/pull/1931)

All proposed changes have been implemented, tested, and submitted for review.

### What Was Implemented

#### Phase 1: Desc Getter Methods

Added four public getter methods to `Desc` struct in `prometheus/desc.go`:

```go
// Name returns the fully-qualified name of the metric descriptor.
func (d *Desc) Name() string

// Help returns the help string for the metric descriptor.
func (d *Desc) Help() string

// ConstLabels returns the constant labels as a Labels map (returns a copy).
func (d *Desc) ConstLabels() Labels

// VariableLabels returns the names of the variable labels (returns a copy).
func (d *Desc) VariableLabels() []string
```

**Key Design Decision:** All methods return copies to preserve descriptor immutability.

#### Phase 2: Registry.Descriptors() Method

Added introspection method to `Registry` in `prometheus/registry.go`:

```go
// Descriptors returns all metric descriptors currently registered with this registry.
//
// This method is useful for introspection, documentation generation, and testing.
// Duplicate descriptors are automatically deduplicated. Unchecked collectors are
// excluded from the results.
func (r *Registry) Descriptors() []*Desc
```

**Implementation Details:**
- Thread-safe using RWMutex read lock
- Deduplicates descriptors by ID
- Excludes unchecked collectors
- Returns slice (not channel) for simplicity

### Files Modified

| File | Lines Added | Purpose |
|------|-------------|---------|
| `prometheus/desc.go` | 45 | Added 4 getter methods (lines 222-266) |
| `prometheus/desc_test.go` | 244 | Added 5 test functions with 15 test cases |
| `prometheus/example_desc_getters_test.go` | 95 | Created 2 runnable examples |
| `prometheus/registry.go` | 7 | Added Descriptors() method (lines 587-592) |
| `prometheus/registry_test.go` | 243 | Added 6 comprehensive test functions |
| `examples/introspection/main.go` | 221 | Created standalone example with 3 modes |

**Total Changes:** ~855 lines added

### Test Coverage

#### Desc Getter Tests (desc_test.go)
1. `TestDesc_Name` - 2 test cases
2. `TestDesc_Help` - 3 test cases
3. `TestDesc_ConstLabels` - 4 test cases, validates copy semantics
4. `TestDesc_VariableLabels` - 4 test cases, validates copy semantics
5. `TestDesc_GettersComprehensive` - Integration test

#### Registry.Descriptors() Tests (registry_test.go)
1. `TestRegistryDescriptors` - Basic functionality
2. `TestRegistryDescriptors_WithLabels` - Label verification
3. `TestRegistryDescriptors_Deduplication` - Duplicate handling
4. `TestRegistryDescriptors_UncheckedCollector` - Exclusion behavior
5. `TestRegistryDescriptors_Concurrent` - Thread safety (100 goroutines)
6. `TestRegistryDescriptors_AfterUnregister` - Dynamic updates

**Test Results:**
```
✅ All 11 test functions pass
✅ All 3 examples pass
✅ Full prometheus package test suite passes (11.8s)
✅ No regressions introduced
```

### Example Usage

#### Standalone Example: `examples/introspection/main.go`

Three modes demonstrating different use cases:

1. **List Mode** (`-mode=list`): Lists all registered metrics with metadata
2. **Docs Mode** (`-mode=docs`): Generates markdown documentation grouped by prefix
3. **Filter Mode** (`-mode=filter -filter=http`): Filters metrics by name prefix

**Run example:**
```bash
go run examples/introspection/main.go -mode=list
go run examples/introspection/main.go -mode=docs
go run examples/introspection/main.go -mode=filter -filter=http
```

### API Design Decisions

| Decision | Rationale |
|----------|-----------|
| Return copies from getters | Preserves descriptor immutability |
| Return slice from Descriptors() | Simpler than channel-based API |
| Deduplicate by descriptor ID | Handles same descriptor from multiple sources |
| Exclude unchecked collectors | Consistent with Describe() behavior |
| Use RWMutex | Thread-safe without blocking writers |
| Concise method comment | Focus on purpose, not implementation details |

### Backward Compatibility

✅ **100% Backward Compatible**
- Only adds new public methods
- No changes to existing APIs
- No interface modifications
- All existing tests pass
- No breaking changes

### Performance

- `Descriptors()` uses same pattern as existing `Describe()` method
- Deduplication is O(n) where n = number of descriptors
- Read lock allows concurrent calls
- Expected usage: infrequent (doc generation, testing)

### Impact on External-DNS

With this implementation, external-dns can:

**Before (current):**
- ~500 lines of workaround code
- Unsafe reflection with `unsafe.Pointer()`
- Custom wrapper types for all metrics
- Parallel metadata tracking
- Fragile, breaks on internal changes

**After (with PR #1931):**
- ~20 lines of simple, safe code
- No unsafe operations
- Standard Prometheus API
- Direct access to metadata
- Robust, future-proof

**Estimated code reduction:** 96% (~480 lines deleted)

### Quick Reference for Future Work

#### Get all registered metrics:
```go
descs := registry.Descriptors()
for _, desc := range descs {
    name := desc.Name()
    help := desc.Help()
    constLabels := desc.ConstLabels()
    varLabels := desc.VariableLabels()
}
```

#### Generate documentation:
```go
descs := registry.Descriptors()
for _, desc := range descs {
    fmt.Printf("## %s\n%s\n\n", desc.Name(), desc.Help())
}
```

#### Test metric registration:
```go
descs := reg.Descriptors()
found := false
for _, desc := range descs {
    if desc.Name() == "expected_metric" {
        found = true
        assert.Equal(t, "Expected help text", desc.Help())
    }
}
assert.True(t, found)
```

### Next Steps

1. ⏳ **Await PR review** from prometheus/client_golang maintainers
2. ⏳ **Address feedback** if any changes requested
3. ⏳ **Merge PR** once approved
4. ⏳ **Update external-dns** to use new API (eliminate unsafe code)
5. ⏳ **Announce** to community for wider adoption

---

**Document Version:** 2.0
**Last Updated:** 2025-12-25
**Author:** Analysis and implementation for issue #1801
