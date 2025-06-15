//
//  ExchangeRateLoader.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

protocol ExchangeRateLoader {
  typealias Result = Swift.Result<LocalExchangeRates, Error>

 func load(completion: @escaping (Result) -> Void)
}
