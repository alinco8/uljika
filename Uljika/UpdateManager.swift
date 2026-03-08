import Sparkle
import AppKit

final class UpdateUserDriverDelegate: NSObject, SPUStandardUserDriverDelegate {
    func standardUserDriverWillShowModalAlert() {
        NSApp.activate()
    }
}

@Observable
class UpdateManager {
    private let controller: SPUStandardUpdaterController
    private let userDriverDelegate = UpdateUserDriverDelegate()
    
    init() {
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: userDriverDelegate)
    }
    
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
