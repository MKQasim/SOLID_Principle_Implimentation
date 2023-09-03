//
//  SOLID_Principle_ImplimentationTests.swift
//  SOLID_Principle_ImplimentationTests
//
//  Created by KamsQue on 18/08/2023.
//


import XCTest

@testable import SOLID_Principle_Implimentation

class HomeViewModelMock: HomeViewModelDelegate {

  var numberOfSections: Int = 0
  var numberOfRows: Int = 0
  var users: [SOLID_Principle_Implimentation.User] = []
  
  func fetchUsers( completion: @escaping SOLID_Principle_Implimentation.UserCompletion) async {
    let user1 = User(login: "user1", id: 1, nodeID: "node1", avatarURL: "avatar1", gravatarID: "gravatar1", url: "url1", htmlURL: "html1", followersURL: "followers1", followingURL: "following1", gistsURL: "gists1", starredURL: "starred1", subscriptionsURL: "subscriptions1", organizationsURL: "organizations1", reposURL: "repos1", eventsURL: "events1", receivedEventsURL: "receivedEvents1", type: .user, siteAdmin: true)
    
    let user2 = User(login: "user2", id: 2, nodeID: "node2", avatarURL: "avatar2", gravatarID: "gravatar2", url: "url2", htmlURL: "html2", followersURL: "followers2", followingURL: "following2", gistsURL: "gists2", starredURL: "starred2", subscriptionsURL: "subscriptions2", organizationsURL: "organizations2", reposURL: "repos2", eventsURL: "events2", receivedEventsURL: "receivedEvents2", type: .user, siteAdmin: false)
    self.users = [user1, user2]
    self.numberOfSections = users.count > 0 ? 1 : 0
    self.numberOfRows = users.count
    completion(.success(users))
  }

  func fetchOutlets(completion: @escaping OutletCompletion) async {
    
    let outlet = Outlet(page: 1, perPage: 10, total: 50, totalPages: 5, data: [
      Datum(city: "City1", name: "Outlet 1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1),
      Datum(city: "City2", name: "Outlet 2", estimatedCost: 40, userRating: UserRating(averageRating: 4.2, votes: 85), id: 2)
    ])
  
    completion(.success(outlet))
  }
  
    // Default implementation for optional methods
//  func fetchEmptyUsers(completion: @escaping UserCompletion) async {
//      // Implement the empty user scenario here
//    self.users = [] // Simulate an empty list of users
//    completion(.success([]))
//   
//  }
//  
//  func fetchEmptyOutlets(completion: @escaping OutletCompletion) async {
//      // Implement the empty outlet scenario here
//    let emptyOutletData: [Datum] = []
//    let emptyOutlet = Outlet(page: 1, perPage: 10, total: 0, totalPages: 0, data: emptyOutletData)
//    completion(.success(nil))
//  }

  
  func cellViewModel(for indexPath: IndexPath) -> SOLID_Principle_Implimentation.UserCellViewModel {
 
    let user = users[indexPath.row]
    return SOLID_Principle_Implimentation.UserCellViewModel(user: user)
  }
}

class UserViewModelDelegateMock: UserViewModelDelegate {
  var users: [SOLID_Principle_Implimentation.User] = []
  var fetchUsers: ((@escaping UserCompletion) -> Void)?

  func fetchUsers(completion: @escaping UserCompletion) async {
    fetchUsers?(completion)
  }
}

class OutletViewModelDelegateMock: OutletViewModelDelegate {
  var outlet: SOLID_Principle_Implimentation.Outlet?
  var fetchOutlets: ((@escaping OutletCompletion) -> Void)?
  
  func fetchOutlets(completion: @escaping OutletCompletion) async {
    fetchOutlets?(completion)
  }
}

class HomeViewModelTests: XCTestCase {
  
  var userViewModel: UserViewModelDelegate!
  var outletViewModel: OutletViewModelDelegate!
  var homeViewModel: HomeViewModelDelegate!
  
  override func setUpWithError() throws {
    userViewModel = UserViewModelDelegateMock()
    outletViewModel = OutletViewModelDelegateMock()
    homeViewModel = HomeViewModelMock()
  }
  
  override func tearDownWithError() throws {
    userViewModel = nil
    outletViewModel = nil
    homeViewModel = nil
  }
  
  func testEmptyUserList() async {
    let expectation = XCTestExpectation(description: "Fetch users expectation")
    (userViewModel as! UserViewModelDelegateMock).users = []
    (userViewModel as! UserViewModelDelegateMock).fetchUsers = { completion in
      completion(.success([]))
    }
    
    await (userViewModel as! UserViewModelDelegateMock).fetchUsers { result in
      switch result {
      case .success(let users):
        XCTAssertEqual(users.count, 0) // Should be 0
        XCTAssertEqual(self.homeViewModel.numberOfRows, 0) // Should also be 0
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testEmptyOutletList() async {
    let expectation = XCTestExpectation(description: "Fetch outlets expectation")
    let emptyOutlet : Outlet?  = nil
   
    (outletViewModel as! OutletViewModelDelegateMock).outlet = nil
    (outletViewModel as! OutletViewModelDelegateMock).fetchOutlets = { completion in
      completion(.success(emptyOutlet))
    }
    
    await (outletViewModel as! OutletViewModelDelegateMock).fetchOutlets { result in
      switch result {
      case .success(let outlet):
        
        XCTAssertEqual(outlet, nil) // Should be 0
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testFetchUsers() async {
    let expectation = XCTestExpectation(description: "Fetch users expectation")
    
    await homeViewModel.fetchUsers { result in
      switch result {
      case .success(let users):
        XCTAssertEqual(users.count, 2)
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testFetchOutlets() async {
    let expectation = XCTestExpectation(description: "Fetch outlets expectation")
    
    await (homeViewModel as! HomeViewModelMock).fetchOutlets { result in
      switch result {
      case .success(let outlet):
        XCTAssertEqual(outlet?.data.count, 2)
        XCTAssertEqual(outlet?.data[0].name, "Outlet 1")
      case .failure:
        XCTFail("Should not fail")
      }
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testNumberOfSections() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers{ [weak self]  result in
      guard let self = self else { return }
      
      if case .success = result {
        XCTAssertEqual(self.homeViewModel.numberOfSections, 1)
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testNumberOfRows() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers { [weak self] result in
      guard let self = self else { return }
      
      if case .success = result {
        XCTAssertEqual(self.homeViewModel.numberOfRows, 2)
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
  
  func testCellViewModelForIndexPath() async {
    let expectation = XCTestExpectation(description: "Fetch users")
    
    await homeViewModel.fetchUsers { [weak self] result in
      guard let self = self else { return }
      
      if case .success = result {
        XCTAssertEqual(self.homeViewModel.numberOfRows, 2)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.homeViewModel.cellViewModel(for: indexPath)
        XCTAssertEqual(cellViewModel.user.login, "user1")
        
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation], timeout: 5)
  }
}
