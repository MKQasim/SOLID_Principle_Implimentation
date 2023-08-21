//
//  ErrorHandler.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 21/08/2023.
//

import Foundation

class APIErrorHelper {
  static func handleAPIError<T>(completion: @escaping (Result<T, APIError>) -> Void, error: APIError) {
    DispatchQueue.main.async {
      completion(.failure(error))
    }
  }
}
