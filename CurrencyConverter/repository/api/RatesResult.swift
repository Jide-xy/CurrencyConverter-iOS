//
//  RatesResult.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import ObjectMapper

struct RatesResult: Mappable{
    init?(map: Map) {
        if map.JSON["base"] == nil {
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        success    <- map["success"]
        date    <- map["date"]
        timeStamp    <- map["timeStamp"]
        base    <- map["base"]
        historical    <- map["historical"]
        rates    <- map["rates"]
    }
    
    var success: Bool!
    var date: String!
    var timeStamp: Int64!
    var base: String!
    var historical: Bool!
    var rates: [String : Double]!
    
}
