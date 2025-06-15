//
//  DefaultExchangeRateRepository.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

/// `DefaultExchangeRateRepository` is a concrete implementation of the `ExchangeRateLoader` protocol.
/// It attempts to load exchange rates from a primary source. If the primary source fails, it falls back
/// to a secondary source to ensure that exchange rates are retrieved. This class is useful for providing
/// a reliable way to fetch exchange rates, even in the face of potential failures from the primary source.
///
/// - Parameters:
///   - primary: An instance conforming to `ExchangeRateLoader` that serves as the primary source for
///              loading exchange rates.
///   - fallback: An instance conforming to `ExchangeRateLoader` that serves as the fallback source
///               if the primary source fails.
///
final class DefaultExchangeRateRepository: ExchangeRateLoader {

  private let primary: ExchangeRateLoader
  private let fallback: ExchangeRateLoader

  init(primary: ExchangeRateLoader, fallback: ExchangeRateLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  func load(completion: @escaping (ExchangeRateLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
      case .success:
        completion(result)
      case .failure: ()
       self?.fallback.load(completion: completion)
      }
    }
  }
}
