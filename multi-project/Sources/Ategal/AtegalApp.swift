import Foundation
import SwiftUI
import SkipFuse
import AtegalCore
import RStudioKit

/// A logger for the Ategal module.
let logger: Logger = Logger(subsystem: "mr.ategal.app", category: "Ategal")

/* SKIP @bridge */
public struct AtegalRootView : View {
    
    /* SKIP @bridge */
    public init() {}

    public var body: some View {
        ContentView()
    }
}

/* SKIP @bridge */
public final class AtegalAppDelegate : Sendable {
    
    /* SKIP @bridge */
    public static let shared = AtegalAppDelegate()

    private init() {}

    /* SKIP @bridge */
    public func onInit() {
        Tracking.bootstrap()
        customizeModuleDependencies()
        logger.debug("onInit")
    }

    /* SKIP @bridge */
    public func onLaunch() {
        logger.debug("onLaunch")
        Tracking.trackEvent()
    }

    /* SKIP @bridge */
    public func onResume() {
        logger.debug("onResume")
    }

    /* SKIP @bridge */
    public func onPause() {
        logger.debug("onPause")
    }

    /* SKIP @bridge */
    public func onStop() {
        logger.debug("onStop")
    }

    /* SKIP @bridge */
    public func onDestroy() {
        logger.debug("onDestroy")
    }

    /* SKIP @bridge */
    public func onLowMemory() {
        logger.debug("onLowMemory")
    }

    private func customizeModuleDependencies() {
        let localizationService = AtegalLocalizationService()
        RStudioKit.ModuleDependencies.localizationService = localizationService
        RStudioKit.ModuleDependencies.accentColor = ColorsPalette.primary
        RStudioKit.ModuleDependencies.primaryColor = ColorsPalette.primary
        RStudioKit.ModuleDependencies.androidCloseIconResourceName = "rs_ic_close"
    }
}
