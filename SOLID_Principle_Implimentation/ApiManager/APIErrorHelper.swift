//
//  ErrorHandler.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 21/08/2023.
//

import Foundation

// MARK: - API Error
enum APIError: Error, Equatable {
    case networkError(Error)
    case decodingError(Error)
    case noDataError(Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let error1), .networkError(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.decodingError(let error1), .decodingError(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.noDataError(let error1), .noDataError(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}


class APIErrorHelper {
  static func handleAPIError<T>(completion: @escaping (Result<T, APIError>) -> Void, error: APIError) {
    DispatchQueue.main.async {
      completion(.failure(error))
    }
  }
}
