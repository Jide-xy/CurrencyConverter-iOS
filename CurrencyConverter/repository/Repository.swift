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
        //        apiService.fetchRxRates(date: "latest").map{ ratesResult in
        //            return ratesResult.rates.map{
        //                RateEntity(currencyCode: $0.key, baseCurrencyCode: ratesResult.base, rate: $0.value)
        //            }
        //        }
        //        .do(onSubscribe: {
        //            response.accept(.Loading(data: self.localDB.getRates().map{$0.toUICurrencyRate()}))
        //        })
        //            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        //            .subscribe(onNext: {value in
        //                self.localDB.saveRates(rates: value)
        //                response.flatMapLatest()
        //            }, onError: { error in
        //
        //            })
        //            .disposed(by: disposeBag)
        //        return response.asObservable()
    }
}
