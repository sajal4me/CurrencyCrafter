//
//  ExchangeRateLoaderCacheDecorator.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

final class ExchangeRateLoaderCacheDecorator: ExchangeRateLoader {

  private let decoratee: ExchangeRateLoader
  private let cache: ExchangeRateCache

  init(decoratee: ExchangeRateLoader, cache: ExchangeRateCache) {
    self.decoratee = decoratee
    self.cache = cache
  }

  func load(completion: @escaping (ExchangeRateLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      completion(result.map { rates in
        self?.cache.saveIgnoringResult(rates)
        return rates
      })
    }
  }
}

private extension ExchangeRateCache {
  func saveIgnoringResult(_ rate: LocalExchangeRates) {
    save(rate) { _ in }
  }
}
