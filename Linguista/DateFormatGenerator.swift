//
//  DateFormatGenerator.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Foundation

class DateFormatGenerator {
    private(set) var result: String? = nil

    private let locale: Locale
    let localeIdentifier: String

    init(localeIdentifier: String) {
        self.localeIdentifier = localeIdentifier
        self.locale = Locale(identifier: localeIdentifier)
    }

    func generate(dateInterval: TMDateInterval, tokenString: String) {

        if dateInterval.duration == 0 {
            self.generate(withSingleDate: dateInterval.start, tokenString: tokenString)
            return
        }

        guard let recommendedDateFormat = DateFormatter.dateFormat(fromTemplate: tokenString, options: 0, locale: self.locale) else {
            return
        }

        let formatter = DateIntervalFormatter()
        formatter.locale = self.locale

        if let value = UserDefaults.standard.object(forKey: "dateStyle") as? DateFormatter.Style.RawValue {
            formatter.dateStyle = DateIntervalFormatter.Style(rawValue: value)!
        }

        if let value = UserDefaults.standard.object(forKey: "timeStyle") as? DateFormatter.Style.RawValue {
            formatter.timeStyle = DateIntervalFormatter.Style(rawValue: value)!
        }

        formatter.dateTemplate = recommendedDateFormat
        self.result = formatter.string(from: dateInterval.start, to: dateInterval.end)
    }

    private func generate(withSingleDate date: Date, tokenString: String) {

        guard let recommendedDateFormat = DateFormatter.dateFormat(fromTemplate: tokenString, options: 0, locale: self.locale) else {
            return
        }

        let formatter = DateFormatter()
        formatter.locale = self.locale

        if let value = UserDefaults.standard.object(forKey: "dateStyle") as? DateFormatter.Style.RawValue {
            formatter.dateStyle = DateFormatter.Style(rawValue: value)!
        }

        if let value = UserDefaults.standard.object(forKey: "timeStyle") as? DateFormatter.Style.RawValue {
            formatter.timeStyle = DateFormatter.Style(rawValue: value)!
        }

        formatter.dateFormat = recommendedDateFormat
        self.result = formatter.string(from: date)
    }
}

extension DateFormatGenerator: Equatable {

    static func ==(genA: DateFormatGenerator, genB: DateFormatGenerator) -> Bool {
        return genA.localeIdentifier == genB.localeIdentifier
    }
}

extension DateFormatGenerator: Hashable {

    var hashValue: Int {
        return self.localeIdentifier.hashValue
    }
}
