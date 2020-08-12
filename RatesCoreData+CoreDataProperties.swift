//
//  RatesCoreData+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//
//

import Foundation
import CoreData


extension RatesCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RatesCoreData> {
        return NSFetchRequest<RatesCoreData>(entityName: "RatesCoreData")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var baseCurrencyCode: String?
    @NSManaged public var rate: Double

}
