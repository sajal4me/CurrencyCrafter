//
//  HTTPClient.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import Foundation

protocol HTTPClientTask {
  func cancel()
}

protocol HTTPClient {
  typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  @discardableResult
  func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
