//
//  OutletViewModel.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 21/08/2023.
//

import Foundation

  // OutletViewModel Delegate
protocol OutletViewModelDelegate {
  var outlet: Outlet? { get set }
  func fetchOutlets(completion: @escaping OutletCompletion) async
  func fetchData(service: OutletServices, completion: @escaping OutletCompletion) async
  func handleFailure(completion: @escaping OutletCompletion, error: APIError)
}

  // OutletViewModel
class OutletViewModel: OutletViewModelDelegate {
  var outlet: Outlet?
  
  let outletServices = OutletServices()
  
  func fetchOutlets(completion: @escaping OutletCompletion) async {
    await fetchData(service: outletServices, completion: completion)
  }
  
  func fetchData(service: OutletServices, completion: @escaping OutletCompletion) async {
    await service.fetchOutlets { result in
      switch result {
      case .success(let outlet):
        self.outlet = outlet
        completion(.success(outlet))
      case .failure(let error):
        self.handleFailure(completion: completion, error: error)
      }
    }
  }
  
   func handleFailure(completion: @escaping OutletCompletion, error: APIError) {
    DispatchQueue.main.async {
        // Handle failure on the main queue
      APIErrorHelper.handleAPIError(completion: completion, error: error)
    }
  }
}
