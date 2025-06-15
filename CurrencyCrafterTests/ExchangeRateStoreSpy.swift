//
//  ExchangeRateStoreSpy.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

class ExchangeRateStoreSpy: ExchangeRateStore {

  enum ReceivedMessage: Equatable {
    case deleteCachedRates
    case insert(LocalExchangeRates, Date)
    case retrieve
  }

  private(set) var receivedMessages = [ReceivedMessage]()

  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletion]()

  func deleteCachedRate(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedRates)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](.failure(error))
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](.success(()))
  }

  func insert(_ rates: CurrencyCrafter.LocalExchangeRates, timestamp: Date, completion: @escaping InsertionCompletion){
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(rates, timestamp))
  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](.failure(error))
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](.success(()))
  }

  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }

  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }

  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.success(.none))
  }

  func completeRetrieval(with rate: LocalExchangeRates, timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.success(CachedExchangeRate(rates: rate, timestamp: timestamp)))
  }
}
