//
//  DateFormatGenerator.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Foundation

struct DateFormatGeneratorResult {
    let recommended: String
    let exact: String
}

class DateFormatGenerator {

    private(set) var result: DateFormatGeneratorResult? = nil

    private let locale: Locale
    let localeIdentifier: String

    init(localeIdentifier: String) {
        self.localeIdentifier = localeIdentifier
        self.locale = Locale(identifier: localeIdentifier)
    }

    func generate(date: Date, tokenString: String) {

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
        let recommendedResult = formatter.string(from: date)

        formatter.dateFormat = tokenString
        let exactResult = formatter.string(from: date)

        self.result = DateFormatGeneratorResult(recommended: recommendedResult, exact: exactResult)
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
