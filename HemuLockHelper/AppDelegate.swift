//
//  AppDelegate.swift
//  HemuHelper
//
//  Created by hades on 2021/4/9.
//

import Cocoa
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let mainAppIdentifier = "cn.hades.HemuLock"
        if (NSRunningApplication.runningApplications(withBundleIdentifier: mainAppIdentifier).count > 0) {
            self.onTerminate()
        }
        // Login start
        let path = Bundle.main.bundlePath as NSString
        var components = path.pathComponents
        components.removeLast()
        components.removeLast()
        components.removeLast()
        components.removeLast()

        let newPath = NSString.path(withComponents: components)
        NSWorkspace.shared.launchApplication(newPath)
        self.onTerminate()
    }

    func onTerminate() {
        NSApp.terminate(nil)
    }
}

