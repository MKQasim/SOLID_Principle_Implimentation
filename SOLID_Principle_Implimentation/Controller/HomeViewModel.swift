  //
  //  HomeViewModel.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 19/08/2023.
  //

import Foundation

struct UserCellViewModel {
  let user: User
}

protocol HomeViewModelDelegate {
  var numberOfSections: Int { get }
  var numberOfRows: Int { get }
  var users: [User] { get }
  func fetchUsers(completion: @escaping UserCompletion) async
  func fetchOutlets(completion: @escaping OutletCompletion) async
  func cellViewModel(for indexPath: IndexPath) -> UserCellViewModel
  
    // Optional methods for testing scenarios
  func fetchEmptyUsers(completion: @escaping UserCompletion) async
  func fetchEmptyOutlets(completion: @escaping OutletCompletion) async
}

extension HomeViewModelDelegate {
    // Default implementation for optional methods
  func fetchEmptyUsers(completion: @escaping UserCompletion) async {
      // Implement the empty user scenario here
  }
  
  func fetchEmptyOutlets(completion: @escaping OutletCompletion) async {
      // Implement the empty outlet scenario here
  }
}

class HomeViewModel: HomeViewModelDelegate {
 
  var users: [User] = []
  
  let userViewModel: UserViewModelDelegate // Use the protocol type here
  let outletViewModel: OutletViewModelDelegate // Use the protocol type here
  
  init(userViewModel: UserViewModelDelegate, outletViewModel: OutletViewModelDelegate) { // Use the protocol type here
    self.userViewModel = userViewModel
    self.outletViewModel = outletViewModel
  }
    // Number of sections in the table view
  var numberOfSections: Int {
    return 1 // You can modify this based on your needs
  }
  
  var numberOfRows: Int {
    return users.count
  }
  
    // Provide the view model for a cell at a given indexPath
  func cellViewModel(for indexPath: IndexPath) -> UserCellViewModel {
    let user = users[indexPath.row]
    return UserCellViewModel(user: user)
  }
  
  func fetchOutlets(completion: @escaping OutletCompletion) async {
    await outletViewModel.fetchOutlets { result in
      switch result {
      case .success(let outlet):
        completion(.success(outlet))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func fetchUsers(completion: @escaping UserCompletion) async {
    await userViewModel.fetchUsers { result in
      switch result {
      case .success(let users):
        self.users = users
        completion(.success(users))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}


