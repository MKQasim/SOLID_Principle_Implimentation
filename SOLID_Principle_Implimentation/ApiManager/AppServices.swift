//
//  UserServices.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 19/08/2023.
//

import Foundation
import NetworkReachability



protocol UserServicesDelegate {
  func fetchUsers(completion: @escaping UserCompletion) async
}

protocol OutletServicesDelegate {
  func fetchOutlets(completion: @escaping OutletCompletion) async
}

class UserServices: UserServicesDelegate {
    let apiManager: ApiManager

    init() {
        let networkReachabilityManager = NetworkMonitor()
        let reqHandler = RequestHandler()
        let responseHandler = ResponseHandler()
        apiManager = ApiManager(
            networkReachabilityManager: networkReachabilityManager ,
            reqHandler: reqHandler,
            responseHandler: responseHandler
        )
    }

    let baseURL = "https://api.github.com/users"
  
    func fetchUsers(completion: @escaping UserCompletion) async {
        await apiManager.request(urlString: baseURL) { result in
            completion(result)
        }
    }
}

class OutletServices: OutletServicesDelegate {
    let apiManager: ApiManager

    init() {
        let networkReachabilityManager = NetworkMonitor()
        let reqHandler = RequestHandler()
        let responseHandler = ResponseHandler()
        apiManager = ApiManager(
            networkReachabilityManager: networkReachabilityManager ,
            reqHandler: reqHandler,
            responseHandler: responseHandler
        )
    }

    let baseURL = "https://jsonmock.hackerrank.com/api/food_outlets?city=seattle&page=1"
  
    func fetchOutlets(completion: @escaping OutletCompletion) async {
        await apiManager.request(urlString: baseURL) { result in
            completion(result)
        }
    }
}
