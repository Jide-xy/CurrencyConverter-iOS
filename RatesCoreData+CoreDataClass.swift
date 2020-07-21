//
//  RatesCoreData+CoreDataClass.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//
//

import Foundation
import CoreData

@objc(RatesCoreData)
public class RatesCoreData: NSManagedObject {

    public func toRateEntity() -> RateEntity {
        RateEntity(currencyCode: self.currencyCode!, baseCurrencyCode: self.baseCurrencyCode!, rate: self.rate)
    }
}
