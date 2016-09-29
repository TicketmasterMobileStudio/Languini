//
//  ResultEntryView.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Cocoa

class ResultEntryView: NSView {

    var localeIdentifier: String = ""
    var index = 0 {
        didSet {
            let brightnessDelta: CGFloat = (self.index % 2 == 0) ? 0.06 : 0.0
            let color = NSColor(white: 0.9 - brightnessDelta, alpha: 1.0)
            self.contentView.backgroundColor = color
        }
    }
    
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var exactValueLabel: NSTextField!
    @IBOutlet weak var recommendedValueLabel: NSTextField!
    @IBOutlet weak private var contentView: ResultEntryContentView!

    static func instanceFromNib(localeIdentifier: String) -> ResultEntryView {

        var views: NSArray = []
        NSNib(nibNamed: "ResultEntryView", bundle: nil)?.instantiate(withOwner: nil, topLevelObjects: &views)
        let resultEntryView = views.filter({($0 as? ResultEntryView) != nil}).first as! ResultEntryView
        resultEntryView.localeIdentifier = localeIdentifier
        return resultEntryView
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let lineRect = NSRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 1.0)
        let intersectRect = lineRect.intersection(dirtyRect)
        if intersectRect.isNull || intersectRect.isEmpty || intersectRect.isInfinite {
            return
        }
        NSColor(white: 0.76, alpha: 1.0).setFill()
        NSRectFill(intersectRect)
    }
}

class ResultEntryContentView: NSView {

    var backgroundColor: NSColor? {
        set(backgroundColor) {
            self.layer?.backgroundColor = backgroundColor?.cgColor
        }
        get {
            if let bgColor = self.layer?.backgroundColor {
                return NSColor(cgColor: bgColor)
            }
            return nil
        }
    }
}
