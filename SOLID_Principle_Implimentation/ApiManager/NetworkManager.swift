  //
  //  NetworkManager.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //

import Foundation
import NetworkReachability


  // MARK: - API Error
enum APIError: Error {
  case networkError(Error)
  case decodingError(Error)
  case noDataError(Error)
}

  // Type Aliases
typealias RequestCompletion<Data> = (Result<Data, APIError>) -> Void
typealias ResponseCompletion<T> = (Result<T, APIError>) -> Void
typealias APIRequestCompletion<T> = (Result<T, APIError>) -> Void


class ApiManager {
  let reqHandler: RequestHandler
  let responseHandler: ResponseHandler
  let networkReachabilityManager: NetworkReachabilityManager
  
  init(networkReachabilityManager: NetworkReachabilityManager = NetworkReachabilityManager(networkMonitor: NetworkMonitor()) ,reqHandler: RequestHandler = RequestHandler(), responseHandler: ResponseHandler = ResponseHandler()) {
    self.networkReachabilityManager = networkReachabilityManager
    self.reqHandler = reqHandler
    self.responseHandler = responseHandler
  }
  
  func request<T: Codable>(urlString: String, completion: @escaping APIRequestCompletion<T>) async {
      // Check the network status before making the request
    switch await NetworkMonitor.networkPath.status {
    case .satisfied:
        // If the network is available, proceed with the request
      if let url = URL(string: urlString) {
        reqHandler.requestData(url: url) { result in
          switch result {
          case .success(let data):
            self.responseHandler.parseModels(data: data, completion: completion)
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    case .unsatisfied, .requiresConnection:
        // If the network is unavailable or requires connection, return an error
      completion(.failure(.networkError(NSError(domain: "Network Error", code: 0, userInfo: nil))))
    default:
        // If the network status is unknown, return an error
      completion(.failure(.networkError(NSError(domain: "Unknown Network Error", code: 0, userInfo: nil))))
    }
  }
}

class RequestHandler {
  func requestData(url: URL, completion: @escaping RequestCompletion<Data>) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(.networkError(error)))
        return
      }
      
      guard let data = data else {
        completion(.failure(.noDataError(NSError(domain: "No Data Error", code: 0, userInfo: nil))))
        return
      }
      
      completion(.success(data))
    }.resume()
  }
}

class ResponseHandler {
  func parseModels<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>) {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    decoder.keyDecodingStrategy = .useDefaultKeys
//    if let rawDataString = String(data: data, encoding: .utf8) {
//      print("Raw Data: \(rawDataString)")
//    }
    do {
      let decodedResponse = try decoder.decode(T.self, from: data)
      completion(.success(decodedResponse))
    } catch {
      completion(.failure(.decodingError(error)))
    }
  }
}



