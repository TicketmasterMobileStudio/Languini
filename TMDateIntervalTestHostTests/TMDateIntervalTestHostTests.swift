//
//  TMDateIntervalTestHostTests.swift
//  TMDateIntervalTestHostTests
//
//  Created by Chris Stroud on 10/3/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import XCTest
@testable import TMDateIntervalTestHost

class TMDateIntervalTestHostTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

//
// MARK: - Initialization
//

extension TMDateIntervalTestHostTests {

    func testCoding_InitDefault() {

        let date = Date()
        let duration: TimeInterval = 0.0

        let interval = TMDateInterval()

        XCTAssertEqual(interval.start, date, "Interval's date should default to the current date")
        XCTAssertEqual(interval.duration, duration, "Interval's duration should be zero by default")
    }
    
}

//
// MARK: - NSCoding
//

extension TMDateIntervalTestHostTests {

    func testCoding_EncodeDecodeSecure() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)

        let data = NSKeyedArchiver.archivedData(withRootObject: intervalA)

        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true

        guard let intervalB = try? unarchiver.decodeTopLevelObject(of: TMDateInterval.self, forKey: NSKeyedArchiveRootObjectKey) else {
            XCTFail("Unable to unarchive root interval object")
            return
        }
        XCTAssertEqual(intervalA, intervalB, "Interval A should be equivalent to interval B")
    }

    func testCoding_EncodeDecodeStandard() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)

        let data = NSKeyedArchiver.archivedData(withRootObject: intervalA)

        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = false

        guard let intervalB = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? TMDateInterval else {
            XCTFail("Unable to unarchive root interval object")
            return
        }
        XCTAssertEqual(intervalA, intervalB, "Interval A should be equivalent to interval B")
    }

}


//
// MARK: - Equality
//

extension TMDateIntervalTestHostTests {

    func testEquals_IdenticalIntervals() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration)

        XCTAssertEqual(intervalA, intervalB, "Interval A should be equivalent to interval B")
    }

    func testEquals_IdenticalIntervalsSwift() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration)

        XCTAssertTrue(intervalA == intervalB, "Interval A should be equivalent to interval B")
    }

    func testEquals_NotEqualIntervals() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration + 1.0)

        XCTAssertNotEqual(intervalA, intervalB, "Interval A should not be equivalent to interval B")
    }

    func testEquals_IncorrectType() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)

        XCTAssertFalse(intervalA.isEqual(""), "Interval A should not be equivalent to a non-TMDateInterval type")
    }

}


//
// MARK: - Contains
//

extension TMDateIntervalTestHostTests {

    func testContains_LowerBoundary() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let interval = TMDateInterval(start: date, duration: duration)
        XCTAssertTrue(interval.contains(date), "Interval should contain the lower boundary value")
    }

    func testContains_UpperBoundary() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let interval = TMDateInterval(start: date, duration: duration)
        XCTAssertTrue(interval.contains(date.addingTimeInterval(duration)), "Interval should contain the upper boundary value")
    }

    func testContains_MidrangeValue() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let interval = TMDateInterval(start: date, duration: duration)
        XCTAssertTrue(interval.contains(date.addingTimeInterval(duration * 0.5)), "Interval should contain midrange value")
    }

    func testContains_InvalidDatePreviousValue() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let interval = TMDateInterval(start: date, duration: duration)
        XCTAssertFalse(interval.contains(date.addingTimeInterval(-duration)), "Interval should not contain date starting before the interval's start date")
    }

    func testContains_InvalidDateFutureValue() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let interval = TMDateInterval(start: date, duration: duration)
        XCTAssertFalse(interval.contains(date.addingTimeInterval(duration * 2.0)), "Interval should not contain date starting after the interval's end date")
    }

}


//
// MARK: - Intersection
//

extension TMDateIntervalTestHostTests {

    func testIntersection_withSelf() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration)
        guard let intersected = intervalA.intersection(with: intervalB) else {
            XCTFail("Intersection should yield non-nil result")
            return
        }

        XCTAssertEqual(intervalA.start, intersected.start)
        XCTAssertEqual(intervalA.duration, intersected.duration)
    }

    func testIntersection_NoOverlap() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(duration + 1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        XCTAssertNil(intervalA.intersection(with: intervalB), "Intersection should yield nil result; the given intervals have no overlap")
    }

    func testIntersection_OperandsOrderedAscending() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        guard let intersected = intervalA.intersection(with: intervalB) else {
            XCTFail("Intersection should yield non-nil result")
            return
        }

        XCTAssertEqual(intersected.start, dateTwo)
        XCTAssertEqual(intersected.duration, duration - dateTwo.timeIntervalSince(dateOne))
    }

    func testIntersection_OperandsOrderedDescending() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        guard let intersected = intervalB.intersection(with: intervalA) else {
            XCTFail("Intersection should yield non-nil result")
            return
        }

        XCTAssertEqual(intersected.start, dateTwo)
        XCTAssertEqual(intersected.duration, duration - dateTwo.timeIntervalSince(dateOne))
    }

}

//
// MARK: - Intersects
//

extension TMDateIntervalTestHostTests {

    func testIntersects_IdenticalInterval() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration)

        XCTAssertTrue(intervalA.intersects(intervalB), "Intersection with self is valid")
    }

    func testIntersects_NoOverlap() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(duration + 1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        XCTAssertFalse(intervalA.intersects(intervalB), "Intervals with no overlap should not intersect")
    }

    func testIntersects_OperandsOrderedAscending() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        XCTAssertTrue(intervalA.intersects(intervalB), "Intersection of intervalA and intervalB is valid")
    }

    func testIntersects_OperandsOrderedDescending() {

        let dateOne = Date()
        let duration: TimeInterval = 10.0

        let dateTwo = dateOne.addingTimeInterval(1.0)

        let intervalA = TMDateInterval(start: dateOne, duration: duration)
        let intervalB = TMDateInterval(start: dateTwo, duration: duration)

        XCTAssertTrue(intervalB.intersects(intervalA), "Intersection of intervalB and intervalA is valid")
    }

}


//
// MARK: - Hashing
//

extension TMDateIntervalTestHostTests {

    func testHashing_IdenticalSetMembers() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration)
        XCTAssertEqual(intervalA.hashValue, intervalB.hashValue, "Identical intervals should yield identical hashes")

        let setOfIntervals = Set([intervalA, intervalB])
        XCTAssertEqual(setOfIntervals.count, 1, "Identical members should hash to the same value in the set")
    }

    func testHashing_DifferingSetMembers() {

        let date = Date()
        let duration: TimeInterval = 10.0

        let intervalA = TMDateInterval(start: date, duration: duration)
        let intervalB = TMDateInterval(start: date, duration: duration + 1.0)
        XCTAssertNotEqual(intervalA.hashValue, intervalB.hashValue, "Identical intervals should yield identical hashes")

        let setOfIntervals = Set([intervalA, intervalB])
        XCTAssertEqual(setOfIntervals.count, 2, "Identical members should hash to the same value in the set")
    }

}
