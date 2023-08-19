  //
  //  NetworkManager.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //

import Foundation


struct ApiManager {
  func callApi<T: Codable>(urlString: String, responseType: T.Type, completion: @escaping (Outlet?, FoodOutletError?) -> Void) {
    if let url = URL(string: urlString) {
      let session = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          completion(nil, .networkError(error))
          return
        }
        
        guard let data = data else {
          completion(nil, .noDataError(NSError(domain: "No Data Error", code: 0, userInfo: nil)))
          return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
          let response = try decoder.decode(Outlet.self, from: data)
          completion(response, nil)
        } catch {
          completion(nil, .decodingError(NSError(domain: "Parsing Error", code: 0, userInfo: nil)))
        }
      }.resume()
    }
  }
}



