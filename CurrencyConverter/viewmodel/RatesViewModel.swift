//
//  RatesViewModel.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 14/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RatesViewModel {
    
    init(repository: Repository) {
        self.repository = repository
        historicalRatesObservable = historicalRatesInputObservable.flatMap{
            repository.getHistoricalRates(numberOfDays: $0)
            }.asDriver(onErrorJustReturn: .Error(message: nil))
        getHistoricalRates(numberOfDays: 30)
        getHistoricalRates(numberOfDays: 90)
    }
    
    let repository: Repository
    
    lazy var ratesObservable = repository.getRates()
    
    let historicalRatesInputObservable = ReplaySubject<Int>.createUnbounded()
    
    let historicalRatesObservable: Driver<NetworkStatus<HistoricalRatesResult>>
    
    func getHistoricalRates(numberOfDays: Int){
        historicalRatesInputObservable.onNext(numberOfDays)
    }
    
}
