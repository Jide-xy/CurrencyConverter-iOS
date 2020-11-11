//
//  HistoricalRatesResult.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 26/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation

struct HistoricalRatesResult {
    let numberOfDays: Int
    let data: [(currency: String, rates: [CurrencyRate])]
}
