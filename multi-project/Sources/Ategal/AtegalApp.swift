import Foundation
import SwiftUI
import SkipFuse
import AtegalCore

/// A logger for the Ategal module.
let logger: Logger = Logger(subsystem: "mr.ategal.app", category: "Ategal")

/// The shared top-level view for the app, loaded from the platform-specific App delegates below.
///
/// The default implementation merely loads the `ContentView` for the app and logs a message.
/* SKIP @bridge */public struct AtegalRootView : View {
    /* SKIP @bridge */public init() {
    }

    public var body: some View {
        ContentView()
    }
}

/// Global application delegate functions.
///
/// These functions can update a shared observable object to communicate app state changes to interested views.
/* SKIP @bridge */public final class AtegalAppDelegate : Sendable {
    /* SKIP @bridge */public static let shared = AtegalAppDelegate()

    private init() {
    }

    /* SKIP @bridge */public func onInit() {
        logger.debug("onInit")
        Tracking.bootstrap()
    }

    /* SKIP @bridge */public func onLaunch() {
        logger.debug("onLaunch")
        Tracking.trackEvent()
    }

    /* SKIP @bridge */public func onResume() {
        logger.debug("onResume")
    }

    /* SKIP @bridge */public func onPause() {
        logger.debug("onPause")
    }

    /* SKIP @bridge */public func onStop() {
        logger.debug("onStop")
    }

    /* SKIP @bridge */public func onDestroy() {
        logger.debug("onDestroy")
    }

    /* SKIP @bridge */public func onLowMemory() {
        logger.debug("onLowMemory")
    }
}
