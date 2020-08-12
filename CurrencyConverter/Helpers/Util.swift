//
//  Util.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 14/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation

struct Util{
    
    static let currencyMap: [String : Locale] = {
        let commonCurrencies = ["USD": "us", "GBP": "gb", "EUR":"eu"]
        let currencies = Locale.isoCurrencyCodes
        var result: [String : Locale] = [:]
        let locales = Locale.availableIdentifiers.map(Locale.init)
        currencies.forEach{ currency in
            result[currency] = locales.first{ locale in
                locale.currencyCode == currency
            }
            let countries = locales.filter{ locale in
                locale.currencyCode == currency
            }
            if !countries.isEmpty {
                if countries.count > 1{
                    if let curr = commonCurrencies[currency]{
                        result[currency] = Locale(identifier: curr)
                    } else {
                        result[currency] = countries[0]
                    }
                } else {
                     result[currency] = countries[0]
                }
            } else {
                 result[currency] = nil
            }
        }
        return result
    }()
}
