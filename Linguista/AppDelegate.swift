//
//  AppDelegate.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var localizationMenu: NSMenu!

    let dateFormatController = DateFormatController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let currentLocale = Locale.current

        var languageToCountryMappings = [String: Set<String>]()
        for localeIdentifier in Locale.availableIdentifiers {

            let locale = Locale(identifier: localeIdentifier)
            if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
                var newValue = languageToCountryMappings[languageCode] ?? Set<String>()
                newValue.insert(regionCode)
                languageToCountryMappings[languageCode] = newValue
            }
        }


        let sortedKeys = languageToCountryMappings.keys.sorted { (keyA, keyB) -> Bool in
            guard let localizedA = currentLocale.localizedString(forLanguageCode: keyA) else {
                return false
            }

            guard let localizedB = currentLocale.localizedString(forLanguageCode: keyB) else {
                return false
            }

            return localizedA < localizedB
        }

        for languageCode in sortedKeys {

            guard let countries = languageToCountryMappings[languageCode] else {
                continue
            }
            guard let localizedLanguageCode = currentLocale.localizedString(forLanguageCode: languageCode) else {
                continue
            }

            let menu = NSMenuItem(title: localizedLanguageCode, action: nil, keyEquivalent: "")
            localizationMenu.addItem(menu)

            let submenu = NSMenu(title: localizedLanguageCode)
            menu.submenu = submenu
            menu.target = self

            let sortedCountries = countries.sorted { (keyA, keyB) -> Bool in

                guard let localizedA = currentLocale.localizedString(forRegionCode: keyA) else {
                    return false
                }

                guard let localizedB = currentLocale.localizedString(forRegionCode: keyB) else {
                    return false
                }

                return localizedA < localizedB
            }

            for country in sortedCountries {

                guard let countryName = currentLocale.localizedString(forRegionCode: country) else {
                    continue
                }
                let menuItem = NSMenuItem(title: countryName, action: nil, keyEquivalent: "")
                menuItem.representedObject = Locale(identifier:"\(languageCode)_\(country)")
                menuItem.action = #selector(didSelectMenuItem(menuItem:))
                menuItem.target = self
                submenu.addItem(menuItem)
            }
        }
    }

    @objc
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {

        guard let localeIdentifier = (menuItem.representedObject as? Locale)?.identifier else {
            return false
        }

        if let _ = self.dateFormatController.generators.filter({$0.localeIdentifier == localeIdentifier}).first {
            return false
        }

        return true
    }

    @objc
    func didSelectMenuItem(menuItem: NSMenuItem?) {

        guard let selectedLocale = menuItem?.representedObject as? Locale else {
            return
        }
        guard let viewController = NSApp.windows.first?.contentViewController as? ViewController else {
            return
        }
        viewController.addLocaleWithIdentifier(withIdentifier: selectedLocale.identifier)
    }

    @IBAction func displayFormatSyntaxReference(_ sender: NSMenuItem) {
        if let url = URL(string: "http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Field_Symbol_Table") {
            NSWorkspace.shared().open(url)
        }
    }
}

