//
//  ExchangeRateCachePolicy.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 15/10/24.
//

import Foundation

/// A struct that defines the policy for validating cached exchange rates.
/// It ensures the freshness of cached data by checking if the cached timestamp
/// falls within the allowed cache age limit. If the data is too old, it is considered stale.
///
/// **Key Details:**
/// - Uses the Gregorian calendar to calculate time differences.
/// - Defines a maximum cache age of 30 minutes.
/// - The `validate` method checks if the cached data is still valid against the current date.
///
/// **Usage:**
/// This policy is applied when loading cached exchange rates to ensure the application
/// displays up-to-date information. If the cache is expired, new data must be fetched.

struct ExchangeRateCachePolicy {
  private init() {} // Prevents instantiation, as this is a utility struct.
  
  private static let calendar = Calendar(identifier: .gregorian)
  
  private static var maxCacheAgeInMinutes: Int {
    return 30
  }
  
  /// Validates whether the cached timestamp is still within the valid range.
  /// - Parameters:
  ///   - timestamp: The time when the data was cached.
  ///   - date: The current date to validate against.
  /// - Returns: `true` if the cached data is still valid, `false` otherwise.
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .minute, value: maxCacheAgeInMinutes, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}
