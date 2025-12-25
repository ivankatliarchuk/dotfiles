# Prow Issue #364: Pin/Unpin Issue Command Implementation Plan

**Issue:** https://github.com/kubernetes-sigs/prow/issues/364
**Status:** ⏸️ BLOCKED - Waiting for PR #556
**Created:** 2025-12-25
**Last Updated:** 2025-12-25

---

## ⚠️ BLOCKER

**Waiting for:** PR #556 - "plugins: add new plugin for linking and unlinking issues to a PR"
- **URL:** https://github.com/kubernetes-sigs/prow/pull/556
- **Status:** OPEN
- **Author:** Amulyam24
- **Description:** Adds a new `issue-management` plugin with commands for linking/unlinking issues to PRs
- **Why blocking:** This PR creates the `issue-management` plugin that we should extend with pin/unpin functionality, rather than creating a separate `pin-issue` plugin
- **Impact on plan:** Once merged, we'll add pin/unpin commands to the existing `issue-management` plugin instead of creating a new plugin

**Action:** Monitor PR #556 and update approach after merge

---

## Overview

**Goal:** Add `/pin-issue` and `/unpin-issue` commands to Prow to allow privileged users to pin/unpin GitHub issues without requiring direct repository write permissions.

**Key Requirements:**
- Enable pinning/unpinning issues via bot commands
- Permission model: Top-level OWNERS approvers (similar to `/override`)
- Works for users who don't have GitHub write permissions
- Uses GitHub GraphQL API mutations

**Existing Work:**
- petr-muller created a WIP implementation at https://github.com/petr-muller/prow/tree/feature/pin-issue-364
- Issue was recently reopened after being auto-closed due to inactivity

---

## Implementation Phases

### Phase 1: Plugin Structure Setup ⏳

**Status:** Not Started

#### 1.1 Create plugin directory structure
- [ ] Create `/pkg/plugins/pin-issue/` directory
- [ ] Create `pin-issue.go` - Main plugin implementation
- [ ] Create `pin-issue_test.go` - Unit tests

#### 1.2 Define core components
- [ ] Plugin name constant: `"pin-issue"`
- [ ] Command regex patterns:
  - `/pin-issue` or `/pin`
  - `/unpin-issue` or `/unpin`
- [ ] GitHub client interface (similar to transfer-issue:42-47)

**Files to create:**
- `/pkg/plugins/pin-issue/pin-issue.go`
- `/pkg/plugins/pin-issue/pin-issue_test.go`

---

### Phase 2: GraphQL Integration ⏳

**Status:** Not Started

#### 2.1 Implement GraphQL mutation structures

Based on GitHub GraphQL schema:

```go
// Pin mutation struct
type pinIssueMutation struct {
    PinIssue struct {
        Issue struct {
            URL githubql.URI
        }
    } `graphql:"pinIssue(input: $input)"`
}

// Unpin mutation struct
type unpinIssueMutation struct {
    UnpinIssue struct {
        Issue struct {
            URL githubql.URI
        }
    } `graphql:"unpinIssue(input: $input)"`
}
```

#### 2.2 Create mutation helper functions
- [ ] `pinIssue(gc, org, issueNodeID)` - Executes pinIssue mutation
- [ ] `unpinIssue(gc, org, issueNodeID)` - Executes unpinIssue mutation
- [ ] Both use `gc.MutateWithGitHubAppsSupport()` like transfer-issue:158

**GraphQL Input Requirements:**
- **PinIssueInput:** `issueId` (required), `clientMutationId` (optional)
- **UnpinIssueInput:** `issueId` (required), `clientMutationId` (optional)

---

### Phase 3: Permission Model ⏳

**Status:** Not Started

#### 3.1 Implement authorization logic

Following override plugin pattern (override.go:229-288):

- [ ] `authorizedUser()` - Check if user is repo admin
- [ ] `authorizedTopLevelOwner()` - Check OWNERS file approvers
- [ ] Optional: `authorizedGitHubTeamMember()` for team-based permissions

**Permission hierarchy:**
1. Repository administrators (always allowed)
2. Top-level OWNERS approvers (if enabled in config)
3. GitHub team members (if configured)

#### 3.2 Add plugin configuration

**Location:** `/pkg/plugins/config.go`

```go
type PinIssue struct {
    AllowTopLevelOwners bool                `json:"allow_top_level_owners,omitempty"`
    AllowedGitHubTeams  map[string][]string `json:"allowed_github_teams,omitempty"`
}
```

- [ ] Add `PinIssue` struct to config.go
- [ ] Add `PinIssue PinIssue` field to `Configuration` struct
- [ ] Update config merging logic if needed

**Files to modify:**
- `/pkg/plugins/config.go`

---

### Phase 4: Command Handling ⏳

**Status:** Not Started

#### 4.1 Implement command handlers

Following transfer-issue pattern:

- [ ] `handleGenericComment()` - Entry point registered with plugin system
- [ ] `handlePinCommand()` - Main logic for parsing and routing commands
- [ ] `handleUnpinCommand()` - Main logic for unpinning

#### 4.2 Validation logic
- [ ] Validate event is an issue (not PR) using `e.IsPR`
- [ ] Validate comment action is "created"
- [ ] Validate command matches regex
- [ ] Validate only one command per comment

#### 4.3 Add user feedback

Success messages:
- "Issue pinned successfully"
- "Issue unpinned successfully"

Error messages:
- "You must be a top-level approver to pin/unpin issues"
- "This command only works on issues, not pull requests"
- "Failed to pin/unpin issue: [error details]"

- [ ] Use `plugins.FormatResponseRaw()` for consistent formatting

---

### Phase 5: Plugin Registration ⏳

**Status:** Not Started

#### 5.1 Register handlers and help

In `pin-issue.go`:

```go
func init() {
    plugins.RegisterGenericCommentHandler(pluginName, handleGenericComment, helpProvider)
}

func helpProvider(config *plugins.Configuration, enabledRepos []config.OrgRepo) (*pluginhelp.PluginHelp, error) {
    // Configure help text
    // Add two commands: /pin-issue and /unpin-issue
    // Specify WhoCanUse based on config
}
```

- [ ] Implement `init()` function
- [ ] Implement `helpProvider()` function
- [ ] Add command help for `/pin-issue`
- [ ] Add command help for `/unpin-issue`

#### 5.2 Update plugin imports

- [ ] Add to `/pkg/plugins/plugins.go` imports: `_ "sigs.k8s.io/prow/pkg/plugins/pin-issue"`

**Files to modify:**
- `/pkg/plugins/plugins.go`

---

### Phase 6: Testing ⏳

**Status:** Not Started

#### 6.1 Write comprehensive tests

Test cases needed:
- [ ] Command parsing (valid/invalid formats)
- [ ] Permission checks (admin, approver, unauthorized)
- [ ] GraphQL mutation execution
- [ ] Error handling (API failures, invalid issue IDs)
- [ ] PR vs Issue validation
- [ ] Multiple commands in one comment (should fail)

Mock components:
- [ ] Use `fakegithub.FakeClient`
- [ ] Mock OWNERS client
- [ ] Mock GraphQL mutations

#### 6.2 Edge cases to handle
- [ ] Issue already pinned (should succeed silently or with message)
- [ ] Issue already unpinned (should succeed silently)
- [ ] Maximum pinned issues limit (GitHub allows 3 per repo)
- [ ] Archived repositories
- [ ] Deleted issues
- [ ] Rate limiting

**Files to create/modify:**
- `/pkg/plugins/pin-issue/pin-issue_test.go`

---

### Phase 7: Documentation ⏳

**Status:** Not Started

#### 7.1 Update documentation
- [ ] Add plugin to enabled plugins list
- [ ] Document configuration options
- [ ] Add examples to command help
- [ ] Update plugins.yaml reference docs
- [ ] Add README.md in plugin directory (optional)

---

### Phase 8: Integration & Validation ⏳

**Status:** Not Started

#### 8.1 Manual testing checklist
- [ ] Test in a real Prow environment
- [ ] Verify permissions work correctly
- [ ] Test with GitHub Apps authentication
- [ ] Validate GraphQL API responses
- [ ] Check comment formatting
- [ ] Ensure logging is adequate

---

## Architecture Decisions

### Why follow transfer-issue pattern?
- Simple, focused plugin doing one thing well
- Clean separation of concerns
- Well-tested pattern in production

### Why use top-level OWNERS approvers?
- Consistent with `/override` plugin
- Doesn't require new permission configuration
- Aligns with existing Prow permission model
- Avoids "permission level creep"

### Why GraphQL instead of REST API?
- GitHub's pinning feature only available via GraphQL
- Consistent with transfer-issue implementation
- Better for complex mutations

### Plugin naming considerations
- **Option A:** `pin-issue` - Focused, clear purpose
- **Option B:** `issue-management` - More extensible for future issue commands ✅ **SELECTED**
- **Decision:** ⚠️ **UPDATED** - PR #556 is creating the `issue-management` plugin. We will extend this plugin with pin/unpin functionality after it's merged, rather than creating a separate plugin

---

## Key Files Reference

### Reference Implementations
- **Transfer-issue plugin:** `/pkg/plugins/transfer-issue/transfer-issue.go`
  - Shows GraphQL mutation pattern
  - Demonstrates org member permission check
- **Override plugin:** `/pkg/plugins/override/override.go`
  - Shows multi-tier authorization (admin, OWNERS, teams)
  - Configuration pattern
  - Lines 229-288: Authorization functions

### Files to Create/Modify (After PR #556 merges)
⚠️ **Note:** File paths will be updated once PR #556 is merged

**Expected to create:**
1. Pin/unpin functionality within `/pkg/plugins/issue-management/` directory
2. Additional test cases in existing test files

**Expected to modify:**
1. `/pkg/plugins/issue-management/issue-management.go` (add pin/unpin handlers)
2. `/pkg/plugins/issue-management/issue-management_test.go` (add pin/unpin tests)
3. `/pkg/plugins/config.go` (extend IssueManagement config struct if needed)

**Original plan (if creating standalone plugin):**
1. `/pkg/plugins/pin-issue/pin-issue.go` (~200-250 lines)
2. `/pkg/plugins/pin-issue/pin-issue_test.go` (~300-400 lines)
3. `/pkg/plugins/config.go` (add PinIssue config struct)
4. `/pkg/plugins/plugins.go` (add import)

---

## GitHub API Details

### GraphQL Mutations

**Pin Issue:**
```graphql
mutation($input: PinIssueInput!) {
  pinIssue(input: $input) {
    issue {
      url
    }
  }
}
```

**Unpin Issue:**
```graphql
mutation($input: UnpinIssueInput!) {
  unpinIssue(input: $input) {
    issue {
      url
    }
  }
}
```

### Required Permissions
- Repository write access OR
- Top-level OWNERS approver (if configured)

---

## Potential Future Enhancements

After initial implementation:
1. Add `/lock-issue` and `/unlock-issue` commands
2. Support pinning to specific positions (GitHub allows up to 3 pins)
3. Bulk operations: `/pin-issues #123 #456`
4. Add metrics/telemetry for usage tracking

---

## Progress Tracking

- [ ] Phase 1: Plugin Structure Setup
- [ ] Phase 2: GraphQL Integration
- [ ] Phase 3: Permission Model
- [ ] Phase 4: Command Handling
- [ ] Phase 5: Plugin Registration
- [ ] Phase 6: Testing
- [ ] Phase 7: Documentation
- [ ] Phase 8: Integration & Validation

---

## Notes

- Issue was auto-closed by k8s-triage-robot but reopened by petr-muller
- petr-muller mentioned using Claude Code to prototype this feature
- WIP code exists but was never polished for PR submission
- Community interest confirmed by multiple commenters

## Next Steps (After PR #556 Merges)

1. **Review PR #556 changes**
   - Examine the `issue-management` plugin structure
   - Understand existing command patterns
   - Review configuration approach
   - Check test patterns used

2. **Update implementation plan**
   - Revise Phase 1 to extend existing plugin instead of creating new one
   - Update file paths to match `issue-management` directory
   - Align with established patterns in the plugin
   - Update config structure to match `IssueManagement` conventions

3. **Begin implementation**
   - Follow the existing plugin's code style
   - Add pin/unpin GraphQL mutations
   - Integrate with existing permission model
   - Add comprehensive tests following existing test patterns

4. **Monitor PR #556**
   - Track review comments for insights
   - Watch for merge conflicts
   - Be ready to start once merged
