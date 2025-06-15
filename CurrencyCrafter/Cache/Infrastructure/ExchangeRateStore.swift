//
//  ExchangeRateStore.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

/// Represents a cached exchange rate with its timestamp for freshness checks.
typealias CachedExchangeRate = (rates: LocalExchangeRates, timestamp: Date)

/// Protocol for storing, deleting, and retrieving cached exchange rates.
protocol ExchangeRateStore {
  typealias DeletionResult = Result<Void, Error>
  typealias DeletionCompletion = (DeletionResult) -> Void

  typealias InsertionResult = Result<Void, Error>
  typealias InsertionCompletion = (InsertionResult) -> Void

  typealias RetrievalResult = Result<CachedExchangeRate?, Error>
  typealias RetrievalCompletion = (RetrievalResult) -> Void

  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func deleteCachedRate(completion: @escaping DeletionCompletion)

  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func insert(_ rates: LocalExchangeRates, timestamp: Date, completion: @escaping InsertionCompletion)

  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func retrieve(completion: @escaping RetrievalCompletion)
}
