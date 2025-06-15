//
//  LocalExchangeRateLoader.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

/// A class responsible for managing the caching and retrieval of exchange rates.
/// It acts as the local data handler, interacting with the `ExchangeRateStore` to delete,
/// insert, and retrieve cached rates. This class also integrates time-based validation for cached data.
///
/// It conforms to `ExchangeRateCache` to handle caching, and `ExchangeRateLoader` to load rates.
/// This design follows the **Single Responsibility Principle**:
/// - It separates caching logic from network operations.
/// - It ensures data freshness using timestamp-based policies.
///
/// **Key Functions**:
/// - `save`: Caches exchange rates by deleting outdated data and inserting new rates.
/// - `load`: Retrieves rates from the cache, validating timestamps to avoid stale data.
final class LocalExchangeRateLoader {
  private let store: ExchangeRateStore
  private let currentDate: () -> Date

  init(store: ExchangeRateStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
}

extension LocalExchangeRateLoader: ExchangeRateCache {
  typealias SaveResult = ExchangeRateCache.Result

  func save(_ rate: LocalExchangeRates, completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedRate { [weak self] deletionResult in
      guard let self = self else { return }

      switch deletionResult {
      case .success:
        self.cache(rate, with: completion)

      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  private func cache(_ rate: LocalExchangeRates, with completion: @escaping (SaveResult) -> Void) {
    store.insert(rate, timestamp: self.currentDate()) { [weak self] insertionResult in
      guard self != nil else { return }

      completion(insertionResult)
    }
  }
}


extension LocalExchangeRateLoader: ExchangeRateLoader {
  typealias LoadResult = ExchangeRateLoader.Result
  
  struct EmptyExchangeRateCache: Error { }

  private struct UnexpectedValuesRepresentation: Error {}
  func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { result in
      switch result {
      case let .failure(error):
        completion(.failure(error))

      case let .success(.some(cache)) where ExchangeRateCachePolicy.validate(cache.timestamp, against: self.currentDate()):
        completion(.success(cache.rates))

      case .success:
        // No Data in DB or Cached expired
        completion(.failure(EmptyExchangeRateCache()))
      }
    }
  }
}
