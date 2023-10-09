  //
  //  NetworkManager.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //

import Foundation
import NetworkReachability
// Type Aliases
typealias RequestCompletion<Data> = (Result<Data, APIError>) -> Void
typealias ResponseCompletion<T> = (Result<T, APIError>) -> Void
typealias APIRequestCompletion<T> = (Result<T, APIError>) -> Void

protocol RequestHandlerProtocol {
    func requestData(url: URL, completion: @escaping RequestCompletion<Data>)
}

protocol ResponseHandlerProtocol {
    func parseModels<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>)
}

protocol NetworkReachabilityManagerProtocol {
    var networkPath: NetworkMonitor { get set }
}

class ApiManager {
    let reqHandler: RequestHandlerProtocol
    let responseHandler: ResponseHandlerProtocol
    let networkReachabilityManager: NetworkMonitor

    init(
        networkReachabilityManager: NetworkMonitor = NetworkMonitor() ,
        reqHandler: RequestHandlerProtocol,
        responseHandler: ResponseHandlerProtocol
    ) {
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

class RequestHandler: RequestHandlerProtocol {
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

class ResponseHandler: ResponseHandlerProtocol {
    func parseModels<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
}




