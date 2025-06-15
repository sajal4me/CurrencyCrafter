//
//  CoreDataExchangeRateStore + ExchangeRateStore.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import CoreData

extension CoreDataExchangeRateStore: ExchangeRateStore {
  /// Deletes the cached exchange rates.
  /// - Parameter completion: A closure called with the result of the deletion.
  func deleteCachedRate(completion: @escaping DeletionCompletion) {
    perform { context in
      completion(Result {
        try ManagedCurrencyExchange.find(in: context).map(context.delete).map(context.save)
        context.reset()
      })
    }
  }

  /// Inserts new exchange rates into the cache with a timestamp.
  /// - Parameters:
  ///   - rates: The exchange rates to insert.
  ///   - timestamp: The time when the rates were fetched.
  ///   - completion: A closure called with the result of the insertion.
  func insert(_ rates: LocalExchangeRates, timestamp: Date, completion: @escaping InsertionCompletion) {
    perform { context in
      completion(Result {
        let managedCache = try ManagedCurrencyExchange.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.rates = ManagedRates.rates(from: rates, in: context)
//        context.reset()
        try context.save()
      })
    }
  }

  /// Retrieves cached exchange rates if available.
  /// - Parameter completion: A closure called with the result of the retrieval.
  func retrieve(completion: @escaping RetrievalCompletion) {
    perform { context in
      completion(Result {
        try ManagedCurrencyExchange.find(in: context).map {
          CachedExchangeRate(LocalExchangeRates(rates: $0.localRates), timestamp: $0.timestamp)
        }
      })
    }
  }
}
