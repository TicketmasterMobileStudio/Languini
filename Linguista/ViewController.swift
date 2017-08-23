//
//  ViewController.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {

    @IBOutlet weak var multiDateCheckbox: NSButton!
    @IBOutlet weak var formatStyleComboBox: NSComboBox!
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!

    @IBOutlet weak var resultStackView: NSStackView!
    @IBOutlet weak var textField: NSTextField! {
        didSet {
            guard let textField = self.textField else { return }
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                self.textFieldDidChange(textField)
            }
        }
    }

    var dateFormatController: DateFormatController {
        get {
            return (NSApp.delegate as! AppDelegate).dateFormatController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatController.delegate = self

        let defaults = UserDefaults.standard
        defaults.register(defaults: ["locales":["en_US", "fr_CA"]])
        
        let values = defaults.array(forKey: "locales") as! [String]
        for localeIdentifier in values {
            self.addLocaleWithIdentifier(withIdentifier: localeIdentifier)
        }

        self.textField.stringValue = "E, MMM d, h:mm a"
        self.textFieldDidChange(self.textField)

        DispatchQueue.main.async {
            NSApp.windows.forEach{
                $0.makeFirstResponder(nil)
            }

            self.textField.isHidden = true
            self.endDatePicker.isHidden = true
            self.startDatePicker.dateValue = Date()
            self.endDatePicker.dateValue = Date()

            self.configureComboBox()

            self.updateResultsList()
        }
    }

    func addLocaleWithIdentifier(withIdentifier identifier: String) {
        self.dateFormatController.addGenerator(generator: DateFormatGenerator(localeIdentifier: identifier))
        self.addRow(localeIdentifier: identifier)
        self.textFieldDidChange(self.textField)
    }

    func removeLocale(withIdentifier identifier: String) {
        if let generator = self.dateFormatController.generators.filter({$0.localeIdentifier == identifier}).first {
            self.dateFormatController.removeGenerator(generator: generator)
        }
        self.removeRow(localeIdentifier: identifier)
    }

    private func configureComboBox() {

        let date = self.startDatePicker.dateValue
        let formatter = DateFormatter()
        let formatStrings = ["EEMMMd", "EEMMMdha", "EEMMMdhmma", "EEMMMdyyyy", "EEMMMdhmmayyyy", "EEMMMdhayyyy"]
        formatStrings.forEach{

            formatter.setLocalizedDateFormatFromTemplate($0)

            let example = formatter.string(from: date)
            let obj = DateFormatterComboBoxRepresentation(formatString: $0, stringRepresentation: example)
            self.formatStyleComboBox.addItem(withObjectValue: obj)
        }

        self.formatStyleComboBox.addItem(withObjectValue: "Custom...")
        self.formatStyleComboBox.selectItem(at: 0)
    }

    @IBAction func textFieldDidChange(_ sender: NSTextField) {
        self.updateResultsList()
    }

    fileprivate func createResultsList() {
        guard let stackView = self.resultStackView else { return }
        stackView.arrangedSubviews.forEach{ view in
            stackView.removeArrangedSubview(view)
        }
    }

    private func addRow(localeIdentifier: String) {

        let view = ResultEntryView.instanceFromNib(localeIdentifier: localeIdentifier)
        view.deleteButton.target = self
        view.deleteButton.action = #selector(deleteButtonSelected)

        self.resultStackView.addArrangedSubview(view)
        self.resultRowsDidChange()
    }

    private func removeRow(localeIdentifier: String) {

        if let generator = self.dateFormatController.generators.filter({$0.localeIdentifier == localeIdentifier}).first {
            self.dateFormatController.removeGenerator(generator: generator)
        }

        for row in self.resultStackView.arrangedSubviews {
            if let row = row as? ResultEntryView, row.localeIdentifier == localeIdentifier {
                self.resultStackView.removeArrangedSubview(row)
                row.removeFromSuperview()
            }
        }
        self.resultRowsDidChange()
    }

    private func resultRowsDidChange() {
        for (index, row) in self.resultStackView.arrangedSubviews.enumerated() {
            if let row = row as? ResultEntryView {
                row.index = index
            }
        }
        self.updatePersistedLocales()
    }

    private func updatePersistedLocales() {
        let currentLocales = self.dateFormatController.generators.map{$0.localeIdentifier}
        UserDefaults.standard.set(currentLocales, forKey: "locales")
        UserDefaults.standard.synchronize()
    }

    @objc func deleteButtonSelected(button: NSButton) {

        DispatchQueue.main.async {
            if let row = button.superview?.superview as? ResultEntryView {
                self.removeRow(localeIdentifier: row.localeIdentifier)
            }
        }
    }

    @IBAction func multiDateCheckboxDidChange(_ sender: NSButton) {

        self.endDatePicker.isHidden = (sender.state != NSOnState)
    }

    @IBAction func startDatePickerDidChangeDates(_ sender: NSDatePicker) {
        self.configureComboBox()
        self.updateResultsList()
    }

    @IBAction func endDatePickerDidChangeDates(_ sender: NSDatePicker) {
        self.updateResultsList()
    }

    @IBAction func dateFormatStyleComboBoxDidChangeValue(_ sender: NSComboBox) {
        self.updateResultsList()
    }

    private func updateResultsList() {

        if let rep = self.formatStyleComboBox.objectValueOfSelectedItem as? DateFormatterComboBoxRepresentation {
            self.textField.isHidden = true
            self.dateFormatController.inputString = rep.formatString
        } else {
            self.textField.isHidden = false
            self.dateFormatController.inputString = self.textField.stringValue
        }

        if self.multiDateCheckbox.state == NSOnState {
            self.dateFormatController.inputDateInterval = TMDateInterval(start: self.startDatePicker.dateValue, end: self.endDatePicker.dateValue)
        } else {
            self.dateFormatController.inputDateInterval = TMDateInterval(start: self.startDatePicker.dateValue, end: self.startDatePicker.dateValue)
        }

    }
}

extension ViewController: DateFormatControllerDelegate {

    func dateFormatControllerDidFailToGenerate(controller: DateFormatController) {

    }

    func dateFormatController(controller: DateFormatController, generatorDidUpdate generator: DateFormatGenerator) {

        for row in self.resultStackView.arrangedSubviews {
            if let row = row as? ResultEntryView, row.localeIdentifier == generator.localeIdentifier {
                let locale = Locale(identifier: row.localeIdentifier)
                if let countryName = locale.localizedString(forLanguageCode: row.localeIdentifier), let regionCode = locale.regionCode {
                    row.titleLabel.stringValue = self.emojiFlag(countryCode: regionCode) + " " + countryName
                } else {
                    row.titleLabel.stringValue = "N/A"
                }
                row.valueLabel.stringValue = generator.result ?? "N/A"
            }
        }
    }

    func emojiFlag(countryCode: String) -> String {
        var string = ""
        var country = countryCode.uppercased()
        for uS in country.unicodeScalars {
            if let scalar = UnicodeScalar(127397 + uS.value) {
                string.append("\(scalar)")
            }
        }
        return string
    }
}

private class DateFormatterComboBoxRepresentation: NSObject, NSCopying {

    fileprivate let formatString: String

    private var stringRepresentation: String = ""

    private override var description: String {
        return self.stringRepresentation
    }

    init(formatString: String, stringRepresentation: String) {
        self.formatString = formatString
        self.stringRepresentation = stringRepresentation
    }

    fileprivate func copy(with zone: NSZone? = nil) -> Any {
        return DateFormatterComboBoxRepresentation(formatString: self.formatString, stringRepresentation: self.stringRepresentation)
    }
}
