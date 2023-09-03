//
//  UserViewModel.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 21/08/2023.
//

import Foundation

  // UserViewModel Delegate
protocol UserViewModelDelegate {
  var users: [User] { get set }
  func fetchUsers(completion: @escaping UserCompletion) async
}

  // UserViewModel
public class UserViewModel: UserViewModelDelegate {
  var users: [User] = []
  let userServices = UserServices()
  
  func fetchUsers(completion: @escaping UserCompletion) async {
    await fetchData(service: userServices, completion: completion)
  }
  
  private func fetchData(service: UserServices, completion: @escaping UserCompletion) async {
    await service.fetchUsers { result in
      switch result {
      case .success(let users):
        self.users = users
        completion(.success(users))
      case .failure(let error):
        self.handleFailure(completion: completion, error: error)
      }
    }
  }
  
  private func handleFailure(completion: @escaping UserCompletion, error: APIError) {
    DispatchQueue.main.async {
        // Handle failure on the main queue
      APIErrorHelper.handleAPIError(completion: completion, error: error)
    }
  }
}
