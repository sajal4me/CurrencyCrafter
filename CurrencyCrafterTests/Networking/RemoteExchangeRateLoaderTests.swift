//
//  RemoteExchangeRateLoaderTests.swift
//  CurrencyCrafterTests
//
//  Created by Sajal Gupta on 13/10/24.
//

import XCTest
@testable import CurrencyCrafter

class RemoteExchangeRateLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load { _ in }

    XCTAssertEqual(client.requestedURLs, [url])
  }

  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load { _ in }
    sut.load { _ in }

    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    })
  }

  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()

    let samples = [199, 201, 300, 400, 500]

    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidData), when: {
        //let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: Data(), at: index)
      })
    }
  }

  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.invalidData), when: {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    })
  }

  func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()

    let item1 = makeItem(rates: ["AED": 3.673,
                                 "AFN": 67.499]
    )
    expect(sut, toCompleteWith: .success(item1.model), when: {
      let json = makeItemsJSON(item1.json)
      client.complete(withStatusCode: 200, data: json)
    })
  }

  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let url = URL(string: "http://any-url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteExchangeRateLoader? = RemoteExchangeRateLoader(url: url, client: client)

    var capturedResults = [RemoteExchangeRateLoader.Result]()
    sut?.load { capturedResults.append($0) }

    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([:]))

    XCTAssertTrue(capturedResults.isEmpty)
  }

  // MARK: - Helpers

  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteExchangeRateLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteExchangeRateLoader(url: url, client: client)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }

  private func failure(_ error: RemoteExchangeRateLoader.Error) -> RemoteExchangeRateLoader.Result {
    return .failure(error)
  }

  private func expect(_ sut: RemoteExchangeRateLoader, toCompleteWith expectedResult: RemoteExchangeRateLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")

    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems)
//        XCTAssertTrue(receivedItems.rates == expectedItems.rates, "The rates dictionaries are not equal.")

      case let (.failure(receivedError as RemoteExchangeRateLoader.Error), .failure(expectedError as RemoteExchangeRateLoader.Error)):

        XCTAssertEqual(receivedError, expectedError, file: file, line: line)

      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()

    wait(for: [exp], timeout: 1.0)
  }

  private func makeItem(rates: [String: Double]) -> (model: LocalExchangeRates, json: [String: Any]) {
    let model = LocalExchangeRates(rates: rates)

    let json = [
      "rates": rates
    ].compactMapValues { $0 }

    return (model, json)
  }

  private func makeItemsJSON(_ items: [String: Any]) -> Data {
    return try! JSONSerialization.data(withJSONObject: items)
  }

}
