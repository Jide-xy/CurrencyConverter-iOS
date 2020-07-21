//
//  RatesService.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import UIKit
import RxAlamofire
import ObjectMapper
import RxSwift

protocol RatesService {
    func fetchRxRates(date:  String) -> Observable<RatesResult>
}

class RatesServiceImpl: RatesService {

    final let BASE_URL = "http://data.fixer.io/api/"
    final let API_KEY = "fef36f32590bfa159328a2ddf302cfc6"
    
    
    func fetchRxRates(date: String) -> Observable<RatesResult>{
        return string(.get, "\(BASE_URL)/\(date)", parameters: ["access_key": "API_KEY"])
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map{
                if let result = RatesResult(JSONString: $0) {
                    return result
                } else {
                    throw ApiError.parsingError(info: "Couldn't parse \($0)")
                }
                }
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
    }
}

enum ApiError: Error {
    case parsingError(info: String)
}

