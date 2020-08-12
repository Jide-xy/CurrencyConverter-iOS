//
//  NetworkStatus.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 14/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation

enum NetworkStatus<T> {
    case Success(T?)
    case Error(message: String?, data: T? = nil)
    case Loading(data: T? = nil)
}
