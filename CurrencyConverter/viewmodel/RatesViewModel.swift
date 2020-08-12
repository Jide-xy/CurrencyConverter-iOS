//
//  RatesViewModel.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 14/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation

class RatesViewModel {
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    let repository: Repository
    
    lazy var ratesObservable = repository.getRates()
    
}
