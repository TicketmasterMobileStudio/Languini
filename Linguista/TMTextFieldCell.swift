//
//  TMTextFieldCell.swift
//  Languini
//
//  Created by Chris Stroud on 8/29/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class TMTextFieldCell: NSTextFieldCell {

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let superRect = super.drawingRect(forBounds: rect)
        let textSize = self.attributedStringValue.size()
        let heightDelta = max((superRect.height - textSize.height), 0.0)

        let newRect = NSMakeRect(superRect.origin.x, heightDelta, superRect.width, textSize.height)
        return newRect
    }
}
