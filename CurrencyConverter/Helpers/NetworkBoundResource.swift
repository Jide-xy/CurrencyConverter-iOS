//
//  NetworkBoundResource.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 26/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkBoundResource {
    func getSynchronizedObservable<ResultType, RequestType>(
        createCall: @escaping () -> Observable<RequestType>,
        remoteCallMapper: @escaping (RequestType) -> Observable<ResultType>,
        loadFromDbRx: @escaping () -> Observable<ResultType>,
        loadFromDb: @escaping () -> ResultType,
        shouldFetch: @escaping (ResultType) -> Bool,
        saveCallResult: @escaping (ResultType) -> Void,
        processResponse: @escaping (RequestType) -> Bool,
        errorParser: ((Error) -> Observable<NetworkStatus<ResultType>>)?
        
    ) -> Observable<NetworkStatus<ResultType>>{
        return Observable<NetworkStatus<ResultType>>.create{observer in
            observer.onNext(.Loading(data: loadFromDb()))
            let disposable = createCall()
                .map(remoteCallMapper).share(replay: 1)
                .flatMapLatest{response -> Observable<NetworkStatus<ResultType>> in
                    saveCallResult(response as! ResultType)
                    return loadFromDbRx().map{ value in
                        NetworkStatus.Success(value)
                    }
            }
            .catchError(errorParser ?? {error in
                let errorMessage: String
                if let error = (error as? ApiError){
                    switch error {
                    case let .parsingError(info):
                        errorMessage = info
                    }
                } else {
                    errorMessage = error.localizedDescription
                }
                return loadFromDbRx().map{NetworkStatus.Error(message: errorMessage, data: $0) }
                })
                .bind(to: observer)
            return disposable
        }
    }
}

