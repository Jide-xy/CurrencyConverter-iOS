//
//  RateEntity.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 12/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation

public struct RateEntity {
    let currencyCode: String
    let baseCurrencyCode: String
    let rate: Double
    
    func toUICurrencyRate() -> CurrencyRate {
        CurrencyRate(currencyCode: self.currencyCode, rate: self.rate,
                     baseCurrencyCode: self.baseCurrencyCode)
    }
}
