//
//  CoreDataExchangeRateStoreTests.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

class CoreDataExchangeRateStoreTests: XCTestCase, FailableFeedStoreSpecs {
  func test_retrieve_deliversFailureOnRetrievalError() {
    let sut = makeSUT()
    assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

  func test_retrieve_hasNoSideEffectsOnFailure() {
    let sut = makeSUT()
    assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
  }

  func test_insert_deliversErrorOnInsertionError() {
    let sut = makeSUT()
    assertThatInsertDeliversErrorOnInsertionError(on: sut)
  }

  func test_insert_hasNoSideEffectsOnInsertionError() {
    let sut = makeSUT()
    assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
  }

  func test_delete_deliversErrorOnDeletionError() {
    let sut = makeSUT()
    assertThatDeleteDeliversErrorOnDeletionError(on: sut)
  }


  //// ubove failling
  func test_delete_hasNoSideEffectsOnDeletionError() {
    let sut = makeSUT()
    assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)

  }


  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }

  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()

    assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
  }

  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()

    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }

  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()

    assertThatSideEffectsRunSerially(on: sut)
  }

  // - MARK: Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ExchangeRateStore {
    let storeURL = URL(fileURLWithPath: "/dev/null")
    let sut = try! CoreDataExchangeRateStore(storeURL: storeURL)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func testSpecificStoreURL() -> URL {
      return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

  private func cachesDirectory() -> URL {
      return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}


extension FailableDeleteExchangeRateStoreSpecs where Self: XCTestCase {
  func assertThatDeleteDeliversErrorOnDeletionError(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
}

extension FailableInsertExchangeRateStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert((uniqueExchangeRate(), Date()), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueExchangeRate(), Date()), to: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
}

extension FailableRetrieveExchangeRateStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: ExchangeRateStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
  }
}
