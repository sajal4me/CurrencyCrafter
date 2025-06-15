//
//  ExchangeRateCache.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation
/// A protocol for abstracting the caching of exchange rates.
/// This separates the caching logic from its implementation, allowing flexibility
/// to swap caching strategies without affecting the rest of the code.
///
/// - `save`: Saves a set of exchange rates to the cache and provides a completion handler
///            to signal success or failure.
protocol ExchangeRateCache {
  typealias Result = Swift.Result<Void, Error>

  /// Saves exchange rates to the cache asynchronously.
  /// - Parameter rate: The exchange rates to be saved.
  /// - Parameter completion: A closure called upon completion with a success or failure result.
  func save(_ rate: LocalExchangeRates, completion: @escaping (Result) -> Void)
}
