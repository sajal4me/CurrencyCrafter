//
//  CurrencyCrafterViewModel.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation


/// `CurrencyCrafterViewModel` is responsible for managing the exchange rate data
/// and providing conversion logic for the CurrencyCrafter app.
/// It interacts with an `ExchangeRateLoader` to fetch exchange rates and provides
/// a clean interface for the view to display and convert currency values.
///
/// Key Responsibilities:
/// - Fetch exchange rates using the provided `ExchangeRateLoader`.
/// - Store and sort the currency codes to populate a picker UI.
/// - Provide currency conversion logic based on the selected currency and amount.
/// - Notify the view on successful data load or error handling using callback closures.
///
/// Properties:
/// - `pickerData`: Sorted list of currency codes used to populate the picker UI.
/// - `exchangeRates`: Stores the exchange rate values for fast access during conversion.
/// - `onLoadExchangeRate`: Callback triggered when exchange rates are successfully loaded.
/// - `onReceivedError`: Callback triggered when an error occurs during the fetching process.
///
/// Methods:
/// - `fetch()`: Loads exchange rates and updates `pickerData` on success or handles errors.
/// - `convertRates(_:selectedCurrency:)`: Converts the given amount from the selected currency
///   to all available currencies and returns the results sorted alphabetically.
///
/// Usage:
/// Initialize the view model with an `ExchangeRateLoader`, call `fetch()` to retrieve data,
/// and use the `convertRates` method to perform conversions.

final class CurrencyCrafterViewModel {
  private let loader: ExchangeRateLoader
  private(set) var pickerData: [String] = []
  private var exchangeRates: [String: Double] = [:]  // Store rates directly for simpler access

  var onLoadExchangeRate: (() -> Void)?
  var onReceivedError: ((String) -> Void)?

  init(loader: ExchangeRateLoader) {
    self.loader = loader
  }

  func fetch() {
    loader.load { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let model):
          self.exchangeRates = model.rates
          self.pickerData = model.rates.keys.sorted()
          self.onLoadExchangeRate?()
        case .failure(let error):
          self.onReceivedError?(error.localizedDescription)
        }
      }
    }
  }

  func convertRates(_ amount: Double, selectedCurrency: String) -> [CurrencyConversionResult] {
    guard let selectedRate = exchangeRates[selectedCurrency] else { return [] }

    return exchangeRates
      .map { CurrencyConversionResult(currency: $0.key, amount: (amount / selectedRate) * $0.value) }
      .sorted(by: { $0.currency < $1.currency })
  }
}

struct CurrencyConversionResult: Hashable {
  let currency: String
  let amount: Double
}
