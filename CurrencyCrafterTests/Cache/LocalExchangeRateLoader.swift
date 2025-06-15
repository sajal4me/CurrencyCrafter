//
//  LocalExchangeRateLoader.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

class LocalExchangeRateLoaderTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()

    sut.save(uniqueExchangeRate()) { _ in }

    XCTAssertEqual(store.receivedMessages, [.deleteCachedRates])
  }

  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    sut.save(uniqueExchangeRate()) { _ in }
    store.completeDeletion(with: deletionError)

    XCTAssertEqual(store.receivedMessages, [ExchangeRateStoreSpy.ReceivedMessage.deleteCachedRates])
  }

  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let rate = uniqueExchangeRate()
    let (sut, store) = makeSUT(currentDate: { timestamp })

    sut.save(rate) { _ in }
    store.completeDeletionSuccessfully()

    XCTAssertEqual(store.receivedMessages, [.deleteCachedRates, .insert(rate, timestamp)])
  }

  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    expect(sut, toCompleteWithError: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }

  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()

    expect(sut, toCompleteWithError: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }

  func test_save_succeedsOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWithError: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }

  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = ExchangeRateStoreSpy()
    var sut: LocalExchangeRateLoader? = LocalExchangeRateLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalExchangeRateLoader.SaveResult]()
    sut?.save(uniqueExchangeRate()) { receivedResults.append($0) }

    sut = nil
    store.completeDeletion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }

  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = ExchangeRateStoreSpy()
    var sut: LocalExchangeRateLoader? = LocalExchangeRateLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalExchangeRateLoader.SaveResult]()
    sut?.save(uniqueExchangeRate()) { receivedResults.append($0) }

    store.completeDeletionSuccessfully()
    sut = nil
    store.completeInsertion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalExchangeRateLoader, store: ExchangeRateStoreSpy) {
    let store = ExchangeRateStoreSpy()
    let sut = LocalExchangeRateLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

  private func expect(_ sut: LocalExchangeRateLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")

    var receivedError: Error?
    sut.save(uniqueExchangeRate()) { result in
      if case let Result.failure(error) = result { receivedError = error }
      exp.fulfill()
    }

    action()
    wait(for: [exp], timeout: 1.0)

    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
  }

  private func uniqueExchangeRate(rates: [String: Double] = ["AED": 3.673,"AFN": 67.499]) -> LocalExchangeRates {
    return LocalExchangeRates(rates: rates)
  }

}
