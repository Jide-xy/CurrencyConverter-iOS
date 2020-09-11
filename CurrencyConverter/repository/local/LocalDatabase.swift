//
//  LocalDatabase.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 12/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

protocol LocalDatabase {
    var ratesObservable: Observable<[RateEntity]> {get}
    func getRates() -> [RateEntity]
    func saveRates(rates: [RateEntity])
    func saveRate(rate: RateEntity)
}
