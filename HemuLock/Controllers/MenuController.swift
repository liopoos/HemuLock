//
//  MenuController.swift
//  HemuLock
//
//  Created by hades on 2024/1/19.
//

import AppKit
import Foundation

class MenuController: NSObject, NSMenuDelegate {
    private var mainMenu = NSMenu()
    private var appConfig = DefaultsManager.shared.getConfig()

    override init() {
        super.init()
        createMenu()
    }

    func getMenu() -> NSMenu {
        return mainMenu
    }

    func createMenu() {
        mainMenu.delegate = self

        // App Version.
        var title = "HemuLock"
        let infoDictionary = Bundle.main.infoDictionary
        if let infoDictionary = infoDictionary {
            let appVersion = infoDictionary["CFBundleShortVersionString"]
            let appName = infoDictionary["CFBundleDisplayName"]
            let appBuild = infoDictionary["CFBundleVersion"]
            title = (appName as! String) + " v\(appVersion!)(\(appBuild!))"
        }

        mainMenu.addItem(withTitle: title, action: nil, keyEquivalent: "").tag = MenuItem.appInfo.tag
        mainMenu.addItem(NSMenuItem.separator())

        mainMenu.addItem(withTitle: "LOCK_NOW".localized, action: #selector(AppDelegate.lockNow), keyEquivalent: "L")
        mainMenu.addItem(NSMenuItem.separator())

        mainMenu.addItem(withTitle: "RUN_SCREENSAVER".localized, action: #selector(AppDelegate.runScreenSaver), keyEquivalent: "S")
        mainMenu.addItem(NSMenuItem.separator())

        // Event sub menu.
        let eventSubMenu = NSMenu()
        for event in Event.allCases {
            eventSubMenu.addItem(withTitle: "EVENT_\(event.name)".localized, action: #selector(AppDelegate.setEvent), keyEquivalent: "").tag = event.tag
            if [Event.screenWake.tag, Event.systemWake.tag].contains(event.tag) {
                eventSubMenu.addItem(NSMenuItem.separator())
            }
        }
        let eventItem = mainMenu.addItem(withTitle: "SET_EVENT".localized, action: nil, keyEquivalent: "")
        eventItem.tag = MenuItem.event.tag
        eventItem.submenu = eventSubMenu
        
        mainMenu.addItem(withTitle: "RECORD_EVENT".localized, action: #selector(AppDelegate.recordEvent), keyEquivalent: "").tag = MenuItem.setEventRecord.tag
        mainMenu.addItem(NSMenuItem.separator())

        var item = mainMenu.addItem(withTitle: "SET_SCRIPT".localized, action: #selector(AppDelegate.setScript), keyEquivalent: "")
        item.tag = MenuItem.setScript.tag
        item.state = appConfig.isExecScript ? .on : .off

        // Notify sub menu.
        let notifySubMenu = NSMenu()
        for notify in Notify.allCases {
            notifySubMenu.addItem(withTitle: notify.name.localized, action: #selector(AppDelegate.setNotify), keyEquivalent: "").tag = notify.tag
            if notify.tag == Notify.none.tag {
                notifySubMenu.addItem(NSMenuItem.separator())
            }
        }
        let notifyItem = mainMenu.addItem(withTitle: "SET_NOTIFY".localized, action: nil, keyEquivalent: "")
        notifyItem.tag = MenuItem.notify.tag
        notifyItem.submenu = notifySubMenu

        // "Send Notify Test" menu item.
        let notifyTestItem = mainMenu.addItem(withTitle: "NOTIFY_TEST".localized, action: #selector(AppDelegate.sendNotifyTest), keyEquivalent: "")
        notifyTestItem.tag = MenuItem.notifyTest.tag
        mainMenu.addItem(NSMenuItem.separator())

        item = mainMenu.addItem(withTitle: "SET_DO_NOT_DISTURB".localized, action: #selector(AppDelegate.setDoNotDisturb), keyEquivalent: "")
        item.tag = MenuItem.setDoNotDisturb.tag
        item.state = appConfig.isDoNotDisturb ? .on : .off
        mainMenu.addItem(NSMenuItem.separator())

        item = mainMenu.addItem(withTitle: "LAUNCH_AT_LOGIN".localized, action: #selector(AppDelegate.setLaunchLogin), keyEquivalent: "")
        item.tag = MenuItem.setLaunchAtLogin.tag
        item.state = appConfig.isLaunchAtLogin ? .on : .off

        item = mainMenu.addItem(withTitle: "SET_PREFERENCES".localized, action: #selector(AppDelegate.openPreferences), keyEquivalent: "")

        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(withTitle: "QUIT".localized, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q")
    }

    @objc func setNotify(_ menuItem: NSMenuItem) {
        appConfig.notifyType = menuItem.tag
        DefaultsManager.shared.setConfig(appConfig)
    }
}
