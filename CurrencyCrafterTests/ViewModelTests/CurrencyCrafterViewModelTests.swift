//
//  CurrencyCrafterViewModelTests.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 18/10/24.
//

import XCTest
@testable import CurrencyCrafter

final class CurrencyCrafterViewModelTests: XCTestCase {

  func testFetch_Success() {
    let rates = ["USD": 1.0, "EUR": 0.85, "JPY": 110.0]
    let sut = makeSUT(loaderResult: .success(LocalExchangeRates(rates: rates)))

    let expectation = expectation(description: "Rates Loaded")

    sut.onLoadExchangeRate = { expectation.fulfill() }
    sut.fetch()

    waitForExpectations(timeout: 1)
    XCTAssertEqual(sut.pickerData, ["EUR", "JPY", "USD"])
    XCTAssertEqual(sut.convertRates(100, selectedCurrency: "USD").count, 3)
  }

  func testPickerData_IsSortedAlphabetically() {
    let expectation = expectation(description: "Rates Loaded")
    let rates = ["USD": 1.0, "EUR": 0.85, "JPY": 110.0]
    let sut = makeSUT(loaderResult: .success(LocalExchangeRates(rates: rates)))
    sut.onLoadExchangeRate = { expectation.fulfill() }
    sut.fetch()

    waitForExpectations(timeout: 1)
    XCTAssertEqual(sut.pickerData, ["EUR", "JPY", "USD"], "Picker data should be sorted alphabetically.")
    XCTAssertNotEqual(sut.pickerData, ["JPY", "USD", "EUR"], "Picker data is not sorted correctly.")
  }

  func testFetch_Failure() {
    let error = NSError(domain: "TestError", code: 1, userInfo: nil)
    let sut = makeSUT(loaderResult: .failure(error))
    let expectation = expectation(description: "Error Received")

    sut.onReceivedError = { errorMessage in
      XCTAssertEqual(errorMessage, error.localizedDescription)
      expectation.fulfill()
    }

    sut.fetch()
    waitForExpectations(timeout: 1)
  }

  func testConvertRates_WithValidCurrency_ReturnsCorrectConversions() {
    let expectation = expectation(description: "Rates Loaded")
    let rates = ["USD": 1.0, "EUR": 0.85, "JPY": 110.0]
    let sut = makeSUT(loaderResult: .success(LocalExchangeRates(rates: rates)))
    sut.onLoadExchangeRate = { expectation.fulfill() }
    sut.fetch()

    waitForExpectations(timeout: 1)

    let result = sut.convertRates(100, selectedCurrency: "USD")

    let expected = [
      CurrencyConversionResult(currency: "EUR", amount: 85.0),
      CurrencyConversionResult(currency: "JPY", amount: 11000.0),
      CurrencyConversionResult(currency: "USD", amount: 100.0)
    ]

    XCTAssertEqual(result, expected, "Conversion results should match expected values.")
  }

  func testConvertRates_InvalidCurrency() {
    let expectation = expectation(description: "Rates Loaded")

    let rates = ["USD": 1.0, "EUR": 0.85, "JPY": 110.0]
    let sut = makeSUT(loaderResult: .success(LocalExchangeRates(rates: rates)))
    sut.onLoadExchangeRate = { expectation.fulfill() }
    sut.fetch()

    waitForExpectations(timeout: 1)

    let result = sut.convertRates(100, selectedCurrency: "GBP")
    XCTAssertTrue(result.isEmpty)
  }

  func testConvertRates_EmptyRates() {
    let expectation = expectation(description: "Rates Loaded")
    let rates: [String: Double] = [:]
    let sut = makeSUT(loaderResult: .success(LocalExchangeRates(rates: rates)))
    sut.onLoadExchangeRate = { expectation.fulfill() }
    sut.fetch()

    waitForExpectations(timeout: 1)
    let result = sut.convertRates(100, selectedCurrency: "USD")

    XCTAssertTrue(result.isEmpty)
    XCTAssertTrue(sut.pickerData.isEmpty)
  }

  // MARK: - Helpers
  private func makeSUT(loaderResult: ExchangeRateLoader.Result, file: StaticString = #file, line: UInt = #line) -> CurrencyCrafterViewModel {
    let loader = ExchangeRateLoaderStub(result: loaderResult)
    let sut = CurrencyCrafterViewModel(loader: loader)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}

