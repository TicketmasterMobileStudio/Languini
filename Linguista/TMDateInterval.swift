//
//  NSDateInterval.swift
//  Languini
//
//  Created by Chris Stroud on 9/29/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Foundation

public final class TMDateInterval: NSObject {

    private(set) public var start: Date
    private(set) public var end: Date
    lazy public var duration: TimeInterval = {
        return self.end.timeIntervalSince(self.start)
    }()

    override required public init() {

        self.start = Date()
        self.end = self.start

        super.init()
    }

    required public init(start startDate: Date, duration: TimeInterval) {

        self.start = startDate
        self.end = self.start.addingTimeInterval(duration)
        super.init()
    }

    convenience required public init(start startDate: Date, end endDate: Date) {

        self.init(start: startDate, duration: endDate.timeIntervalSince(startDate))
    }

    public func compare(_ dateInterval: TMDateInterval) -> ComparisonResult {

        let startComparison = self.start.compare(dateInterval.start)
        if (startComparison == .orderedAscending) || (startComparison == .orderedSame && (self.duration < dateInterval.duration)) {
            return .orderedAscending
        }

        let endComparison = self.end.compare(dateInterval.end)
        if (endComparison == .orderedDescending) || (endComparison == .orderedSame && (self.duration > dateInterval.duration)) {
            return .orderedDescending
        }

        return .orderedSame
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let dateInterval = object as? TMDateInterval else {
            return false
        }
        let startDatesEqual = (self.start.compare(dateInterval.start) == .orderedSame)
        let durationsEqual = (self.duration == dateInterval.duration)
        return (startDatesEqual && durationsEqual)
    }

    public func intersects(_ dateInterval: TMDateInterval) -> Bool {
        return (self.intersection(with: dateInterval) != nil)
    }

    public func intersection(with dateInterval: TMDateInterval) -> TMDateInterval? {

        let latterInterval  = (self.compare(dateInterval) == .orderedDescending) ? self : dateInterval
        let earlierInterval = (self.compare(dateInterval) == .orderedAscending)  ? self : dateInterval

        if latterInterval.start.compare(earlierInterval.end) == .orderedDescending {
            return nil
        }

        let startDate = latterInterval.start
        let endDate = (earlierInterval.end.compare(latterInterval.end) != .orderedDescending) ? earlierInterval.end : latterInterval.end

        let intersectedInterval = TMDateInterval(start: startDate, end: endDate)
        return intersectedInterval
    }

    public func contains(_ date: Date) -> Bool {

        if self.start.compare(date) == .orderedDescending {
            return false
        }

        if self.end.compare(date) == .orderedAscending {
            return false
        }

        return true
    }
}

extension TMDateInterval: NSSecureCoding {

    private struct CodingKeys {
        static let startDate = "startDate"
        static let duration = "duration"
    }

    public convenience init?(coder aDecoder: NSCoder) {

        guard let startDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.startDate) as? Date else {
            return nil
        }

        let duration = aDecoder.decodeDouble(forKey: CodingKeys.duration)

        self.init(start: startDate, duration: TimeInterval(duration))
    }

    @objc(encodeWithCoder:) public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.start, forKey: CodingKeys.startDate)
        aCoder.encode(self.duration, forKey: CodingKeys.duration)
    }

    public static var supportsSecureCoding: Bool {
        return true
    }
}

extension TMDateInterval {

    public static func ==(rangeA: TMDateInterval, rangeB: TMDateInterval) -> Bool {
        return rangeA.compare(rangeB) == .orderedSame
    }

    public override var hashValue: Int {
        return self.start.hashValue ^ self.end.hashValue
    }
}
