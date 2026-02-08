# Bowzer Improvements TODO

## High Priority

### Code Quality
- [x] **Eliminate duplicate code in services** - `detectBrowsers()` and `detectBrowsersResult()` are 95% identical in `BrowserDetectionService.swift`, same pattern in `ProfileDetectionService` and `URLLaunchService`
- [x] **Implement proper error handling** - errors are currently `print()`ed and silently swallowed, no user feedback when launches fail
- [x] **Replace magic numbers with constants** - hardcoded values like `keyCode == 53` for Escape, `42` for icon positioning

### Architecture
- [ ] **Refactor AppState** - currently a god object managing browsers, settings, 4 services, and display items
- [x] **Add logging framework** - replace 17+ bare `print()` statements with os.log
- [x] **Decouple views from services** - views directly call multiple services in sequence (e.g., `BrowsersTab.swift:56-59`)

### Test Coverage
- [ ] **Add AppDelegate tests** - 193 lines of critical lifecycle code with no tests
- [x] **Add AppState tests** - `applyBrowserOrder()`, `saveDisplayItemOrder()`, `moveDisplayItems()` untested
- [x] **Add integration tests** - full browser detection → profile detection → settings flow
- [x] **Add error scenario tests** - browser not found, corrupted profiles, JSON failures, launch failures

## Medium Priority

### Missing Features
- [ ] **Support keyboard shortcuts beyond 1-9** - users with 10+ profiles can't use keyboard
- [ ] **Add search/filter in picker** - for users with many browsers/profiles
- [ ] **Track recent/favorite browsers** - remember user's most-used selections
- [ ] **Add URL routing rules** - e.g., "send GitHub links to Arc"
- [ ] **Support default profile per browser** - preferred profile without using picker
- [ ] **Add profile icon/color differentiation** - visually distinguish profiles of same browser

### UX Improvements
- [ ] **Add visual feedback on selection** - brief highlight when pressing number keys
- [ ] **Add empty state message** - helpful message when all browsers are hidden
- [ ] **Fix fragile positioning logic** - replace hardcoded pixel values with dynamic calculation
- [ ] **Read version from bundle** - currently hardcoded as "1.0" in AboutView

### Settings & Persistence
- [x] **Add settings save debouncing** - prevent multiple writes when rapidly toggling browsers
- [x] **Clean up ghost browser entries** - remove uninstalled browsers from settings
- [x] **Validate Launch at Login setup** - check entitlements before attempting SMAppService registration

## Lower Priority

### Performance
- [ ] **Optimize browser detection sorting** - O(n²) sorting can be improved with lookup map
- [ ] **Improve Firefox profile parsing** - more efficient line parsing

### Accessibility
- [ ] **Add accessibilityLabel to browser items** - describe browser name and action
- [ ] **Add accessibilityHint for shortcuts** - announce "Press 1 to select this browser"
- [ ] **Declare accessibility traits** - `.isButton` for interactive items
- [ ] **Improve color contrast** - keyboard shortcut badges need better visibility
