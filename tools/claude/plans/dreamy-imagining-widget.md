# Move createDomainFilter to Endpoint Package

## Overview
Refactor `createDomainFilter` from `controller/execute.go` to the `endpoint` package, addressing the TODO comments in both the implementation and tests.

## Current State
- **Function**: `controller/execute.go:466-475` with TODO: "move to endpoint package"
- **Test**: `controller/execute_test.go:335-470` with TODO: "this test should live in endpoint package"
- **Usage**: Single call site at `controller/execute.go:117`

## Implementation Strategy

### Architectural Constraint
The `endpoint` package cannot import `externaldns.Config` due to dependency direction (`pkg/apis/externaldns` → `endpoint`). Solution: use individual parameters instead of config struct.

### New Function Design
```go
// In endpoint/domain_filter.go
func NewDomainFilterFromConfig(
    domainFilter []string,
    excludeDomains []string,
    regexDomainFilter *regexp.Regexp,
    regexDomainExclusion *regexp.Regexp,
) *DomainFilter
```

This function will:
- Be exported (public) - tests and providers can use it
- Follow existing endpoint package patterns (simple parameters)
- Preserve the logic: regex filters take precedence over plain filters
- Match naming convention: similar to `NewDomainFilterWithExclusions`

## Implementation Steps

### 1. Add Factory Function to Endpoint Package
**File**: `endpoint/domain_filter.go`
**Location**: After line 96 (after `NewRegexDomainFilter`)

Add `NewDomainFilterFromConfig` with:
- Full GoDoc explaining regex precedence behavior
- Same logic as current `createDomainFilter`
- ~15 lines of code

### 2. Migrate Tests to Endpoint Package
**File**: `endpoint/domain_filter_test.go`
**Location**: End of file (after line 1041)

Create `TestNewDomainFilterFromConfig` by:
- Copying all 15 test cases from `controller/execute_test.go:335-470`
- Adapting setup to use explicit parameters instead of `externaldns.Config`
- Removing dependency on `externaldns` package
- ~150 lines of test code

Example transformation:
```go
// Before (controller)
cfg := &externaldns.Config{RegexDomainFilter: regexp.MustCompile(`example\.com`)}
filter := createDomainFilter(cfg)

// After (endpoint)
filter := NewDomainFilterFromConfig(nil, nil, regexp.MustCompile(`example\.com`), nil)
```

### 3. Update Controller Call Site
**File**: `controller/execute.go`

Replace line 117:
```go
domainFilter := endpoint.NewDomainFilterFromConfig(
    cfg.DomainFilter,
    cfg.ExcludeDomains,
    cfg.RegexDomainFilter,
    cfg.RegexDomainExclusion,
)
```

Delete lines 466-475 (old `createDomainFilter` function and TODOs)

### 4. Remove Old Test from Controller
**File**: `controller/execute_test.go`

Delete lines 335-470 (`TestCreateDomainFilter` function)

### 5. Verify Implementation
Run tests:
```bash
go test ./endpoint/...      # New tests pass
go test ./controller/...    # Controller tests still pass
go test ./...               # Full suite passes
```

## Files Modified
1. ✏️ `endpoint/domain_filter.go` - Add new factory function
2. ✏️ `endpoint/domain_filter_test.go` - Add 15 test cases
3. ✏️ `controller/execute.go` - Update call site, remove old function
4. ✏️ `controller/execute_test.go` - Remove old tests

## Success Criteria
- [ ] All 15 test cases pass in new location
- [ ] No circular import dependencies
- [ ] Controller tests pass
- [ ] No references to `createDomainFilter` remain
- [ ] Domain filtering behavior unchanged
