//
//  DefaultExchangeRateRepositoryTests.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

class DefaultExchangeRateRepositoryTests: XCTestCase {

  func test_load_deliversRate_fromLocal() {
    let rates = uniqueExchangeRate()
    let sut = makeSUT(localLoaderResult: .success(rates), remoteLoaderResult: nil)
    expect(sut, toCompleteWith: .success(rates))
  }

  func test_load_deliversRateFromRemote_localFails() {
    let rates = uniqueExchangeRate()
    let sut = makeSUT(localLoaderResult: .failure(anyNSError()), remoteLoaderResult: .success(rates))
    expect(sut, toCompleteWith: .success(rates))
  }


  // MARK: - Helpers
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, 
                       localLoaderResult: ExchangeRateLoader.Result?,
                       remoteLoaderResult: ExchangeRateLoader.Result?,
                       file: StaticString = #file,
                       line: UInt = #line) -> ExchangeRateLoader {

    let localLoader = ExchangeRateLoaderStub(result: localLoaderResult)
    let remoteLoader = ExchangeRateLoaderStub(result: remoteLoaderResult)

    let sut = DefaultExchangeRateRepository(primary: localLoader, fallback: remoteLoader)
    trackForMemoryLeaks(localLoader, file: file, line: line)
    trackForMemoryLeaks(remoteLoader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return sut
  }


  private func uniqueExchangeRate() -> LocalExchangeRates {
    return LocalExchangeRates(rates: ["AED": 3.673, "AFN": 67.499])
  }

  private func expect(_ sut: ExchangeRateLoader, toCompleteWith expectedResult: ExchangeRateLoader.Result, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")

    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedRates), .success(expectedRates)):
        XCTAssertEqual(receivedRates, expectedRates, file: file, line: line)

      case (.failure, .failure):
        break

      default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }
}
