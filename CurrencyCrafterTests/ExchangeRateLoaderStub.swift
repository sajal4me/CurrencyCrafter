//
//  ExchangeRateLoaderStub.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import Foundation
@testable import CurrencyCrafter

class ExchangeRateLoaderStub: ExchangeRateLoader {
  private let result: ExchangeRateLoader.Result!

  init(result: ExchangeRateLoader.Result?) {
    self.result = result
  }

  func load(completion: @escaping (ExchangeRateLoader.Result) -> Void) {
    print("sajal ExchangeRateLoaderStub load(completion: 1")
    completion(result)
  }
}
