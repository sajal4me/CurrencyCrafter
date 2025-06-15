//
//  XCTestCase+ExchangeRateSpecs.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

extension ExchangeRateSpecs where Self: XCTestCase {

  func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let rate = uniqueExchangeRate()
    let timestamp = Date()
    insert((rate, timestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedExchangeRate(rates: rate, timestamp: timestamp)), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let rate = uniqueExchangeRate()
    let timestamp = Date()

    insert((rate, timestamp), to: sut)

    expect(sut, toRetrieveTwice: .success(CachedExchangeRate(rates: rate, timestamp: timestamp)), file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert((uniqueExchangeRate(), Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueExchangeRate(), Date()), to: sut)

    let insertionError = insert((uniqueExchangeRate(), Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
  }

  func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueExchangeRate(), Date()), to: sut)
    let latestRate = uniqueExchangeRate()
    let latestTimestamp = Date()
    insert((latestRate, latestTimestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedExchangeRate(rates: latestRate, timestamp: latestTimestamp)), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueExchangeRate(), Date()), to: sut)

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
  }

  func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueExchangeRate(), Date()), to: sut)

    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatSideEffectsRunSerially(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    var completedOperationsInOrder = [XCTestExpectation]()

    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueExchangeRate(), timestamp: Date()) { _ in
      completedOperationsInOrder.append(op1)
      op1.fulfill()
    }

    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedRate { _ in
      completedOperationsInOrder.append(op2)
      op2.fulfill()
    }

    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueExchangeRate(), timestamp: Date()) { _ in
      completedOperationsInOrder.append(op3)
      op3.fulfill()
    }

    waitForExpectations(timeout: 5.0)

    XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
  }

  func uniqueExchangeRate(rates: [String: Double] = ["AED": 3.673,"AFN": 67.499]) -> LocalExchangeRates {
    return LocalExchangeRates(rates: rates)
  }
}


extension ExchangeRateSpecs where Self: XCTestCase {
  @discardableResult
  func insert(_ cache: (rate: LocalExchangeRates, timestamp: Date), to sut: ExchangeRateStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.rate, timestamp: cache.timestamp) { result in
      if case let Result.failure(error) = result { insertionError = error }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }

  @discardableResult
  func deleteCache(from sut: ExchangeRateStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedRate { result in
      if case let Result.failure(error) = result { deletionError = error }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }

  func expect(_ sut: ExchangeRateStore, toRetrieveTwice expectedResult: ExchangeRateStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }

  func expect(_ sut: ExchangeRateStore, toRetrieve expectedResult: ExchangeRateStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")

    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
      case (.success(.none), .success(.none)),
         (.failure, .failure):
        break

      case let (.success(.some(expected)), .success(.some(retrieved))):
        XCTAssertEqual(retrieved.rates, expected.rates, file: file, line: line)
        XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }
}

