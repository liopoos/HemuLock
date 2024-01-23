//
//  AppDelegate.swift
//  hemu
//
//  Created by hades on 2021/3/31.
//

import Cocoa
import DefaultsKit
import LaunchAtLogin
import ServiceManagement
import Settings
import SwiftUI

var appState = AppStateContainer()

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate {
    private var mainMenu: NSMenu!
    private var statusItem: NSStatusItem!
    private var observer: EventObserver?
    private var window: NSWindow!

    private let menuController = MenuController()

    private lazy var settingsWindowController = SettingsWindowController(
        panes: [
            GeneraPanelViewController(),
            NotifyPanelViewController(),
            DoNotDisturbPanelViewController(),
        ],
        style: .toolbarItems
    )

    func menuWillOpen(_ menu: NSMenu) {
        updateRecordsMenu()
        updateMenuState(menu)
        updateSubMenu(menu)
    }

    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }

    func updateMenuState(_ menu: NSMenu) {
        if let item = menu.item(withTag: MenuItem.setScript.tag) {
            item.state = appState.appConfig.isExecScript ? .on : .off
        }

        if let item = menu.item(withTag: MenuItem.setDoNotDisturb.tag) {
            item.state = appState.appConfig.isDoNotDisturb ? .on : .off
        }

        if let item = menu.item(withTag: MenuItem.setLaunchAtLogin.tag) {
            item.state = appState.appConfig.isLaunchAtLogin ? .on : .off
        }
    }

    func updateSubMenu(_ menu: NSMenu) {
        if let infoItem = menu.item(withTag: MenuItem.appInfo.tag) {
            let appStatusImg = NSImage(named: DisturbModeManager.shared.inDisturb() ? "AppStatus_Disturb" : "AppStatus_Run")
            appStatusImg?.size = NSSize(width: 15, height: 15)
            infoItem.image = appStatusImg
        }

        if let eventItem = menu.item(withTag: MenuItem.event.tag) {
            let eventList = appState.appConfig.activeEvents
            for item in eventItem.submenu!.items {
                if eventList.contains(item.tag) {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }

        if let notifyItem = menu.item(withTag: MenuItem.notify.tag) {
            for item in notifyItem.submenu!.items {
                item.state = item.tag == appState.appConfig.notifyType ? .on : .off
            }
        }

        if let notifyTestItem = menu.item(withTag: MenuItem.notifyTest.tag) {
            notifyTestItem.isHidden = appState.appConfig.notifyType == Notify.none.tag
        }
    }

    func updateRecordsMenu() {
        let itemTag = MenuItem.eventRecord.tag
        let records = RecordRepository.shared.getRecords(limit: 12)

        // Remove all associated Tag items first.
        for item in mainMenu.items where item.tag == itemTag {
            mainMenu.removeItem(item)
        }

        if records.count <= 0 {
            return
        }

        // Add event records to main menu.
        let recordSubMenu = NSMenu()
        for record in records {
            let recordSubMenuItem = NSMenuItem(title: record.event, action: nil, keyEquivalent: "")
            recordSubMenuItem.title = record.event

            let eventTitle = "EVENT_\(record.event)".localized
            let eventTime = record.time.toLocalString()
            let attributedString = NSMutableAttributedString(string: "\(eventTitle)\n\(eventTime)")
            attributedString.addAttributes([.font: NSFont.systemFont(ofSize: 12)], range: NSRange(location: 0, length: eventTitle.count))
            attributedString.addAttributes([.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.gray], range: NSRange(location: eventTitle.count + 1, length: eventTime.description.count))
            recordSubMenuItem.attributedTitle = attributedString

            recordSubMenu.addItem(recordSubMenuItem)
            recordSubMenu.addItem(NSMenuItem.separator())
        }

        let recordMenuItem = NSMenuItem(title: "EVENT_RECORDS".localized, action: nil, keyEquivalent: "")
        recordMenuItem.tag = itemTag
        recordMenuItem.submenu = recordSubMenu
        mainMenu.insertItem(recordMenuItem, at: 7)
    }

    // MARK: Menu event.

    @objc func lockNow() {
        return sleepNow()
    }

    @objc func runScreenSaver() {
        NSWorkspace.shared.launchApplication("ScreenSaverEngine")
    }

    @objc func sendNotifyTest() {
        observer?.sendNotify()
    }

    @objc func updateMenu() {
        statusItem.menu = mainMenu
        statusItem.button?.performClick(nil)
    }

    // MARK: Event function.

    @objc func setScript(_ menuItem: NSMenuItem) {
        appState.appConfig.isExecScript = !appState.appConfig.isExecScript
        menuItem.state = appState.appConfig.isExecScript ? .on : .off
    }

    @objc func setNotify(_ menuItem: NSMenuItem) {
        appState.appConfig.notifyType = menuItem.tag
    }

    @objc func setEvent(_ menuItem: NSMenuItem) {
        var eventList = appState.appConfig.activeEvents
        if eventList.contains(menuItem.tag) {
            eventList = eventList.filter { $0 != menuItem.tag }
        } else {
            eventList.append(menuItem.tag)
        }
        appState.appConfig.activeEvents = eventList
    }

    @objc func setDoNotDisturb(_ menuItem: NSMenuItem) {
        appState.appConfig.isDoNotDisturb = !appState.appConfig.isDoNotDisturb
        menuItem.state = appState.appConfig.isDoNotDisturb ? .on : .off
    }

    @objc func setLaunchLogin(_ menuItem: NSMenuItem) {
        appState.appConfig.isLaunchAtLogin = !appState.appConfig.isLaunchAtLogin
        LaunchAtLogin.isEnabled = appState.appConfig.isLaunchAtLogin
        menuItem.state = appState.appConfig.isLaunchAtLogin ? .on : .off
    }

    @objc func openPreferences(_ menuItem: NSMenuItem) {
        settingsWindowController.show()
    }

    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Hide Main view.
        if let window = NSApplication.shared.windows.first {
            window.close()
        }

        mainMenu = menuController.getMenu()
        mainMenu.delegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = mainMenu

        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.image?.size = NSSize(width: 20, height: 20)
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(updateMenu)
        }

        observer = EventObserver()
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("good night!")
    }
}
