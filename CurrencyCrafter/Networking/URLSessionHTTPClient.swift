//
//  URLSessionHTTPClient.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

/// URLSessionHTTPClient is a concrete implementation of the HTTPClient protocol.
/// It uses URLSession to perform HTTP requests and wraps URLSession tasks to support cancellation.
/// The get method initiates a data task, processes the response or error,
/// and returns the result via a completion handler.
final class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession

  init(session: URLSession) {
    self.session = session
  }

  private struct UnexpectedValuesRepresentation: Error {}

  private struct URLSessionTaskWrapper: HTTPClientTask {
    let wrapped: URLSessionTask

    func cancel() {
      wrapped.cancel()
    }
  }

  /// Initiates a GET request to the given URL.
  /// - Returns: A task conforming to HTTPClientTask that can be cancelled.
  /// - On completion, it returns either data and response or an error.
  func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
    let task = session.dataTask(with: url) { data, response, error in
      completion(Result {
        if let error = error {
          throw error
        } else if let data = data, let response = response as? HTTPURLResponse {
          return (data, response)
        } else {
          throw UnexpectedValuesRepresentation()
        }
      })
    }
    task.resume()
    return URLSessionTaskWrapper(wrapped: task)
  }
}
