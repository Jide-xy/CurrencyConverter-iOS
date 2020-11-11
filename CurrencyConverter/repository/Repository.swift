//
//  Repository.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import RxSwift
import RxCocoa

protocol Repository {
    func getRates() -> Observable<NetworkStatus<[CurrencyRate]>>
    func getHistoricalRates(numberOfDays: Int) -> Observable<NetworkStatus<HistoricalRatesResult>>
}

class RepositoryImpl: Repository {
    
    
    let apiService: RatesService
    let localDB: LocalDatabase
    
    var disposeBag = DisposeBag()
    
    init(apiService: RatesService, localDB: LocalDatabase) {
        self.apiService = apiService
        self.localDB = localDB
    }
    
    func getRates() -> Observable<NetworkStatus<[CurrencyRate]>> {
        //let response = BehaviorRelay<NetworkStatus<[CurrencyRate]>?>(value: nil)
        return Observable<NetworkStatus<[CurrencyRate]>>.create{observer in
            observer.onNext(.Loading(data: self.localDB.getRates().map{$0.toUICurrencyRate()}))
            let disposable = self.apiService.fetchRxRates(date: "latest")
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .map{ ratesResult in
                    return ratesResult.rates.map{
                        RateEntity(currencyCode: $0.key, baseCurrencyCode: ratesResult.base, rate: $0.value)
                    }
            }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .share(replay: 1)
                .flatMapLatest{rates -> Observable<NetworkStatus<[CurrencyRate]>> in
                    self.localDB.saveRates(rates: rates)
                    return self.localDB.ratesObservable.map{ value in
                        NetworkStatus.Success(value.map{$0.toUICurrencyRate()})
                    }
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .catchError{error in
                let errorMessage: String
                if let error = (error as? ApiError){
                    switch error {
                    case let .parsingError(info):
                        errorMessage = info
                    }
                } else {
                    errorMessage = error.localizedDescription
                }
                return self.localDB.ratesObservable.map{NetworkStatus.Error(message: errorMessage, data: $0.map{ rate in
                    rate.toUICurrencyRate()
                }) }
            }
            .bind(to: observer)
            return disposable
        }
    }
    
    func getHistoricalRates(numberOfDays: Int) -> Observable<NetworkStatus<HistoricalRatesResult>> {
        var datesFromNow: [String] = []
        let today = Date()
        let formatter = DateFormatter(withFormat: "yyyy-MM-dd", locale: "en_US")
        datesFromNow.append(formatter.string(from: today))
        for i in 1...4 {
            datesFromNow.append(formatter.string(from: Calendar.current.date(byAdding: .day, value: (numberOfDays / 5) * -i, to: Date())!))
        }
        datesFromNow.reverse()
        let uiFormatter = DateFormatter(withFormat: "dd MMM", locale: "en_US")
        return Observable.zip(datesFromNow.map{self.apiService.fetchRxRates(date: $0)})
        .map {
            NetworkStatus.Success(HistoricalRatesResult(numberOfDays: numberOfDays, data: $0.map{rate in
                (uiFormatter.string(from: formatter.date(from: rate.date)!),
                    rate.rates.map{key, value in CurrencyRate(currencyCode: key, rate: value, baseCurrencyCode: rate.base, date: rate.date)})
            }))
            }
        .catchError{error in
            let errorMessage: String
            if let error = (error as? ApiError){
                switch error {
                case let .parsingError(info):
                    errorMessage = info
                }
            } else {
                errorMessage = error.localizedDescription
            }
            return .just(NetworkStatus.Error(message: errorMessage))
        }
        .startWith(.Loading())
    }
}
