import Foundation
import Combine

class AppState: ObservableObject {
    @Published var browsers: [Browser] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var orderedDisplayItems: [BrowserDisplayItem] = []

    let browserDetectionService = BrowserDetectionService()
    let profileDetectionService = ProfileDetectionService()
    let urlLaunchService = URLLaunchService()
    let settingsService = SettingsService()

    init() {
        // Set up bindings
        browserDetectionService.appState = self
        profileDetectionService.appState = self
        settingsService.appState = self
    }

    func applyBrowserOrder() {
        // Get all display items from browsers
        let allItems = browsers.flatMap { $0.displayItems }

        guard !settings.browserOrder.isEmpty else {
            orderedDisplayItems = allItems
            return
        }

        var orderedItems: [BrowserDisplayItem] = []
        var remainingItems = allItems

        for itemId in settings.browserOrder {
            if let index = remainingItems.firstIndex(where: { $0.id == itemId }) {
                orderedItems.append(remainingItems.remove(at: index))
            }
        }

        // Append any items not in the saved order
        orderedItems.append(contentsOf: remainingItems)
        orderedDisplayItems = orderedItems
    }

    func saveDisplayItemOrder() {
        settings.browserOrder = orderedDisplayItems.map { $0.id }
        settingsService.saveSettings()
    }

    func moveDisplayItems(from source: IndexSet, to destination: Int) {
        orderedDisplayItems.move(fromOffsets: source, toOffset: destination)
        saveDisplayItemOrder()
    }
}
