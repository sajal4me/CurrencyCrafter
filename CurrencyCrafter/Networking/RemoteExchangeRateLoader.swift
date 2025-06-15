//
//  RemoteExchangeRateLoader.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

/// RemoteExchangeRateLoader fetches exchange rate data from a given URL using a HTTPClient protocol.
/// It returns the result through a completion handler, handling both success and failure scenarios.
final class RemoteExchangeRateLoader: ExchangeRateLoader {
  private let url: URL
  private let client: HTTPClient

  enum Error: Swift.Error {
    case connectivity
    case invalidData
  }

  typealias Result = ExchangeRateLoader.Result

  init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }

  func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }

      switch result {
      case let .success((data, response)):
        completion(RemoteExchangeRateLoader.map(data, from: response))

      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }

  private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try ExchangeRateMapper.map(data, from: response)
      return .success(items)
    } catch {
      return .failure(error)
    }
  }
}

struct ExchangeRateMapper {
  private struct RemoteExchangeRates: Codable {
    let rates: [String: Double]
  }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> LocalExchangeRates {
    guard response.isOK, let model = try? JSONDecoder().decode(RemoteExchangeRates.self, from: data) else {
      throw RemoteExchangeRateLoader.Error.invalidData
    }
    return LocalExchangeRates(rates: model.rates)
  }
}


