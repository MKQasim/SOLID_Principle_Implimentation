  //
  //  NetworkManager.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //

import Foundation

typealias APICompletion<Data> = (Result<Data, FoodOutletError>) -> Void
typealias ResponseCompletion<T> = (Result<T, FoodOutletError>) -> Void
typealias APIRequest<T> = (Result<T, FoodOutletError>) -> Void


class ApiManager {
  let apiHandler: APIHandler
  let responseHandler: ResponseHandler
  
  init(apiHandler: APIHandler = APIHandler(), responseHandler: ResponseHandler = ResponseHandler()) {
    self.apiHandler = apiHandler
    self.responseHandler = responseHandler
  }
  
  func request<T: Codable>(urlString: String, completion: @escaping APIRequest<T>) {
    if let url = URL(string: urlString) {
      apiHandler.request(url: url) { result in
        switch result {
        case .success(let data):
          self.responseHandler.parse(data: data, completion: completion)
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}

class APIHandler {
  func request(url: URL, completion: @escaping APICompletion<Data>) {
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
  func parse<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>) {
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









