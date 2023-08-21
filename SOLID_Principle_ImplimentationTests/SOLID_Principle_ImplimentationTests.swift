//
//  SOLID_Principle_ImplimentationTests.swift
//  SOLID_Principle_ImplimentationTests
//
//  Created by KamsQue on 18/08/2023.
//


import XCTest

@testable import SOLID_Principle_Implimentation

enum APIError: Error {
  case networkError(Error?)
  case decodingError(Error)
}

typealias UserCompletion = (Result<[User], APIError>) -> Void
typealias OutletCompletion = (Result<Outlet, APIError>) -> Void

protocol UserViewModelDelegate {
  func fetchUsers(completion: @escaping UserCompletion) async
}

protocol OutletViewModelDelegate {
  func fetchOutlets(completion: @escaping OutletCompletion) async
}

class HomeViewModelMock: HomeViewModelDelegate {
  var numberOfSections: Int = 1
  var numberOfRows: Int = 2
  var users: [SOLID_Principle_Implimentation.User] = []
  
  func fetchUsers(completion: @escaping SOLID_Principle_Implimentation.UserCompletion) async {
      // Simulate a successful fetch of users
    let user1 = User(login: "user1", id: 1, nodeID: "node1", avatarURL: "avatar1", gravatarID: "gravatar1", url: "url1", htmlURL: "html1", followersURL: "followers1", followingURL: "following1", gistsURL: "gists1", starredURL: "starred1", subscriptionsURL: "subscriptions1", organizationsURL: "organizations1", reposURL: "repos1", eventsURL: "events1", receivedEventsURL: "receivedEvents1", type: .user, siteAdmin: true)
      
    let user2 = User(login: "user2", id: 2, nodeID: "node2", avatarURL: "avatar2", gravatarID: "gravatar2", url: "url2", htmlURL: "html2", followersURL: "followers2", followingURL: "following2", gistsURL: "gists2", starredURL: "starred2", subscriptionsURL: "subscriptions2", organizationsURL: "organizations2", reposURL: "repos2", eventsURL: "events2", receivedEventsURL: "receivedEvents2", type: .user, siteAdmin: false)
    
    
    self.users = [user1, user2]
    completion(.success(users))
  }
  
  func fetchOutlets(completion: @escaping SOLID_Principle_Implimentation.OutletCompletion) async {
      // Simulate a successful fetch of outlets
          let outlet = Outlet(page: 1, perPage: 10, total: 50, totalPages: 5, data: [
            Datum(city: "City1", name: "Outlet 1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1),
            Datum(city: "City2", name: "Outlet 2", estimatedCost: 40, userRating: UserRating(averageRating: 4.2, votes: 85), id: 2)
          ])
        completion(.success(outlet))
  }
  
  func cellViewModel(for indexPath: IndexPath) -> SOLID_Principle_Implimentation.UserCellViewModel {
 
    let user = users[indexPath.row]
    return SOLID_Principle_Implimentation.UserCellViewModel(user: user)
  }
}

class UserViewModelDelegateMock: UserViewModelDelegate {
  func fetchUsers(completion: @escaping UserCompletion) async {}
}

class OutletViewModelDelegateMock: OutletViewModelDelegate {
  func fetchOutlets(completion: @escaping OutletCompletion) async {}
}

class HomeViewModelTests: XCTestCase {
  
  var userViewModel: UserViewModelDelegate!
  var outletViewModel: OutletViewModelDelegate!
  var homeViewModel: HomeViewModelDelegate! // Corrected type
  
  override func setUpWithError() throws {
    userViewModel = UserViewModelDelegateMock()
    outletViewModel = OutletViewModelDelegateMock()
    homeViewModel = HomeViewModelMock()
  }
  
  func testFetchUsers() async {
    let expectation = XCTestExpectation(description: "Fetch users expectation")
    
    await (homeViewModel).fetchUsers { result in
      switch result {
      case .success(let users):
        XCTAssertEqual(users.count, 2) // Assuming the mock implementation returns 2 users
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 5)
  }
  
  func testFetchOutlets() async {
    let expectation = XCTestExpectation(description: "Fetch outlets expectation")
    
    await (homeViewModel as! HomeViewModelMock).fetchOutlets { result in
      switch result {
      case .success(let outlet):
        XCTAssertEqual(outlet.data.count, 2) // Assuming the mock implementation returns 2 outlets
        XCTAssertEqual(outlet.data[0].name, "Outlet 1") // Assuming the name of the first outlet is "Outlet 1"
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
  }
  
  func testNumberOfSections() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers { [weak self] result in
      guard let self = self else {
        return
      }
      
      if case .success = result {
        XCTAssertEqual(self.homeViewModel.numberOfSections, 1)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }
  
  func testNumberOfRows() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers { [weak self] result in
      guard let self = self else {
        return
      }
      
      if case .success = result {
        XCTAssertEqual(self.homeViewModel.numberOfRows, 2) // Assuming the mock implementation has 2 users
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }

  
  func testCellViewModelForIndexPath() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers { [weak self] result in
      guard let self = self else {
        return
      }
      
      if case .success = result {
          // Assuming the mock implementation returns 2 users
        XCTAssertEqual(self.homeViewModel.numberOfRows, 2)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.homeViewModel.cellViewModel(for: indexPath)
        XCTAssertEqual(cellViewModel.user.login, "user1")
        
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10)
  }
}
