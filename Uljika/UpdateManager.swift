import Sparkle
import AppKit

final class UpdateUserDriverDelegate: NSObject, SPUStandardUserDriverDelegate {
    func standardUserDriverWillShowModalAlert() {
        NSApp.activate()
    }
}

@Observable
final class UpdateManager {
    static let shared = UpdateManager()
    
    private let controller: SPUStandardUpdaterController
    private let userDriverDelegate = UpdateUserDriverDelegate()
    
    private init() {
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: userDriverDelegate)
    }
    
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
