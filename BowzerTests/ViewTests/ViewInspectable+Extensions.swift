import SwiftUI
import ViewInspector
@testable import Bowzer

// MARK: - ViewInspector Conformance Extensions

// ViewInspector 0.10+ no longer requires explicit Inspectable conformance
// as all SwiftUI views are now automatically inspectable.
// These extensions are kept for backwards compatibility but may be removed
// in a future update.

extension BrowserItemView: @retroactive Inspectable {}
extension PickerView: @retroactive Inspectable {}
extension SettingsView: @retroactive Inspectable {}
extension BrowsersTab: @retroactive Inspectable {}
extension PreferencesTab: @retroactive Inspectable {}
extension SetupTab: @retroactive Inspectable {}
extension AboutView: @retroactive Inspectable {}
extension KeyboardEventHandler: @retroactive Inspectable {}
