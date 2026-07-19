---
name: write-go-test
description: Write Go tests for Go codebases. Use when asked to write tests, add test coverage, create unit tests, or generate tests for Go code. Triggers on requests like "write tests for this Go code", "add test coverage", "create unit tests for my Go package", or when working with _test.go files.
---

# Go Test Writing

## Workflow

1. **Analyze existing test patterns**
   - Find existing `_test.go` files in the codebase
   - Note: table-driven vs individual tests, assertion style, mocking approach, test helpers
   - Match the established patterns

2. **Identify what needs testing**
   - Run `git diff develop` (or appropriate base branch) to see changes
   - Focus tests on new/modified code paths

3. **Write tests following codebase conventions**

## Rules

- **Use PascalCase for test names** — never underscores (e.g., `TestUserCreate` not `Test_User_Create`)
- **Never modify implementation code** — if code is hard to test, note it in a comment but don't refactor
- **Match existing test style** — use the same assertion library, mocking approach, and structure as other tests in the repo

## Quick Reference

```go
// Standard test structure
func TestFeatureBehavior(t *testing.T) {
    // arrange
    // act
    // assert
}

// Table-driven (if repo uses this pattern)
func TestFeature(t *testing.T) {
    tests := []struct {
        name string
        // inputs and expected outputs
    }{
        // test cases
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // test logic
        })
    }
}
```
