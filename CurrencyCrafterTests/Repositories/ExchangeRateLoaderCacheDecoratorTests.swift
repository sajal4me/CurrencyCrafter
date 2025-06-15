//
//  ExchangeRateLoaderCacheDecoratorTests.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 24/10/24.
//

import XCTest
@testable import CurrencyCrafter

class ExchangeRateLoaderCacheDecoratorTests: XCTestCase {

  func test_load_deliversRateOnLoaderSuccess() {
    let rates = uniqueExchangeRate()
    let sut = makeSUT(loaderResult: .success(rates))

    expect(sut, toCompleteWith: .success(rates))
  }

  func test_load_deliversErrorOnLoaderFailure() {
    let sut = makeSUT(loaderResult: .failure(anyNSError()))

    expect(sut, toCompleteWith: .failure(anyNSError()))
  }

  func test_load_cachesLoadedRateOnLoaderSuccess() {
    let cache = CacheSpy()
    let rates = uniqueExchangeRate()
    let sut = makeSUT(loaderResult: .success(rates), cache: cache)

    sut.load { _ in }

    XCTAssertEqual(cache.messages, [.save(rates)], "Expected to cache loaded rates on success")
  }

  func test_load_doesNotCacheOnLoaderFailure() {
    let cache = CacheSpy()
    let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

    sut.load { _ in }

    XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache rates on load error")
  }

  // MARK: - Helpers

  private func makeSUT(loaderResult: ExchangeRateLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> ExchangeRateLoader {
    let loader = ExchangeRateLoaderStub(result: loaderResult)
    let sut = ExchangeRateLoaderCacheDecorator(decoratee: loader, cache: cache)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private class CacheSpy: ExchangeRateCache {
    private(set) var messages = [Message]()

    enum Message: Equatable {
      case save(LocalExchangeRates)
    }

    func save(_ rate: LocalExchangeRates, completion: @escaping (ExchangeRateCache.Result) -> Void) {
      messages.append(.save(rate))
      completion(.success(()))
    }
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
