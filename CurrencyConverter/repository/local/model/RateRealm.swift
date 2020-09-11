//
//  RateRealm.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import RealmSwift

class RateRealm: Object{
    
    @objc dynamic var currencyCode: String? = nil
    @objc dynamic var baseCurrencyCode: String? = nil
    @objc dynamic var rate: Double = 0.0
    
    public func toRateEntity() -> RateEntity {
        RateEntity(currencyCode: self.currencyCode!, baseCurrencyCode: self.baseCurrencyCode!, rate: self.rate)
    }
    
    override static func primaryKey() -> String? {
        return "currencyCode"
    }
}
