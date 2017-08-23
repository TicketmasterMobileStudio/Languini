//
//  DateFormatController.swift
//  Linguista
//
//  Created by Chris Stroud on 8/26/16.
//  Copyright © 2016 Ticketmaster. All rights reserved.
//

import Foundation

protocol DateFormatControllerDelegate {
    func dateFormatControllerDidFailToGenerate(controller: DateFormatController)
    func dateFormatController(controller: DateFormatController, generatorDidUpdate: DateFormatGenerator)
}

class DateFormatController: NSObject {

    var delegate: DateFormatControllerDelegate? = nil

    private(set) var generators = [DateFormatGenerator]()  {
        didSet {
            self.reloadGenerators()
        }
    }

    var inputString: String? = nil {
        didSet {
            self.reloadGenerators()
        }
    }

    var inputDateInterval = TMDateInterval(start: Date(), end: Date()) {
        didSet {
            self.reloadGenerators()
        }
    }

    func addGenerator(generator: DateFormatGenerator) {

        if self.generators.contains(generator) == false {
            self.generators.append(generator)
        }
    }

    func removeGenerator(generator: DateFormatGenerator) {
        if let index = self.generators.index(of: generator) {
            self.generators.remove(at: index)
        }
    }

    func reloadGenerators() {

        guard let inputString = self.inputString else {
            self.delegate?.dateFormatControllerDidFailToGenerate(controller: self)
            return
        }

        for generator in self.generators {
            generator.generate(dateInterval: self.inputDateInterval, tokenString: inputString)
            self.delegate?.dateFormatController(controller: self, generatorDidUpdate: generator)
        }
    }
}
