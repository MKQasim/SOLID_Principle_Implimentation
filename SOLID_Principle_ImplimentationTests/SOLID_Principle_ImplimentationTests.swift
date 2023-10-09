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
    
    func cellViewModel(for indexPath: IndexPath) -> SOLID_Principle_Implimentation.UserCellViewModel {
        
        let user = users[indexPath.row]
        return SOLID_Principle_Implimentation.UserCellViewModel(user: user)
    }
}

class OutletViewModelDelegateMock: OutletViewModelDelegate {
    func fetchData(service: SOLID_Principle_Implimentation.OutletServices, completion: @escaping SOLID_Principle_Implimentation.OutletCompletion) async {
        fetchOutlets?(completion)
    }
    
    func handleFailure(completion: @escaping SOLID_Principle_Implimentation.OutletCompletion, error: SOLID_Principle_Implimentation.APIError) {
        completion(.failure(error))
    }
    
    var outlet: SOLID_Principle_Implimentation.Outlet?
    var fetchOutlets: ((@escaping OutletCompletion) -> Void)?
    
    func fetchOutlets(completion: @escaping OutletCompletion) async {
        fetchOutlets?(completion)
    }
}

// Define a typealias for the closure type
typealias HandleFailureClosure = (@escaping UserCompletion, APIError) -> Void

class UserViewModelDelegateMock: UserViewModelDelegate {
    var userServices: SOLID_Principle_Implimentation.UserServices = UserServices()
    
    
    func fetchData(service: SOLID_Principle_Implimentation.UserServices = UserServices() , completion: @escaping SOLID_Principle_Implimentation.UserCompletion) async {
        fetchUsers?(completion)
    }
    
    func handleFailure(completion: @escaping SOLID_Principle_Implimentation.UserCompletion, error: SOLID_Principle_Implimentation.APIError) {
            completion(.failure(error))
    }
    
    var users: [SOLID_Principle_Implimentation.User] = []
    
    // Use the typealias for handleFailure
    var handleFailure: HandleFailureClosure?
    
    var fetchUsers: ((@escaping UserCompletion) -> Void)?
    
    func fetchUsers(completion: @escaping UserCompletion) async {
        fetchUsers?(completion)
    }
}

import XCTest

class UserViewModelTests: XCTestCase {
    var userViewModel: UserViewModelDelegate!
    var userViewModelMock: UserViewModelDelegateMock!

    override func setUp() {
        super.setUp()
        userViewModel = UserViewModel()
        userViewModelMock = UserViewModelDelegateMock()
    }

    // MARK: - Test Cases

    // Mocked UserServices
    class MockUserServices: UserServices {
        override func fetchUsers(completion: @escaping UserCompletion) async {
            // Mocked user data
            let users: [User] = [
                User(login: "user1", id: 1, nodeID: "node1", avatarURL: "avatar1", gravatarID: "gravatar1", url: "url1", htmlURL: "html1", followersURL: "followers1", followingURL: "following1", gistsURL: "gists1", starredURL: "starred1", subscriptionsURL: "subscriptions1", organizationsURL: "organizations1", reposURL: "repos1", eventsURL: "events1", receivedEventsURL: "receivedEvents1", type: .user, siteAdmin: true),
                User(login: "user2", id: 2, nodeID: "node2", avatarURL: "avatar2", gravatarID: "gravatar2", url: "url2", htmlURL: "html2", followersURL: "followers2", followingURL: "following2", gistsURL: "gists2", starredURL: "starred2", subscriptionsURL: "subscriptions2", organizationsURL: "organizations2", reposURL: "repos2", eventsURL: "events2", receivedEventsURL: "receivedEvents2", type: .user, siteAdmin: false)
            ]
            completion(.success(users))
        }
    }

    // Test the fetchUsers method
    func testFetchUsers() async {
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Fetch users expectation")

        // Inject the mock UserServices
        userViewModel = UserViewModel()
        userViewModel.userServices = MockUserServices()

        // Perform the fetchUsers operation and wait for completion
        await userViewModel.fetchUsers { result in
            switch result {
            case .success(let users):
                // Assert that the user list is not empty
                if let users = users {
                    XCTAssertFalse(users.isEmpty, "User list should not be empty")
                }

                // Assert that the numberOfRows in the HomeViewModel is equal to the user count
                XCTAssertEqual(self.userViewModel.users.count, users?.count, "numberOfRows should be equal to user count")

            case .failure:
                XCTFail("Should not fail")
            }

            // Fulfill the expectation to indicate completion
            expectation.fulfill()
        }

        // Wait for the expectation to be fulfilled (timeout: 5 seconds)
        wait(for: [expectation], timeout: 5)
    }

    // Test the fetchData method
    func testFetchData() async {
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Fetch Data expectation")

        // Inject the mock UserServices
        userViewModel = UserViewModel()
        userViewModel.userServices = MockUserServices()

        // Perform the fetchData operation and wait for completion
        await userViewModel.fetchData(service: UserServices()) { result in
            switch result {
            case .success(let users):
                // Assert that the user list is not empty
                if let users = users {
                    XCTAssertFalse(users.isEmpty, "User list should not be empty")
                }

                // Assert that the numberOfRows in the HomeViewModel is equal to the user count
                XCTAssertEqual(self.userViewModel.users.count, users?.count, "numberOfRows should be equal to user count")

            case .failure:
                XCTFail("Should not fail")
            }

            // Fulfill the expectation to indicate completion
            expectation.fulfill()
        }

        // Wait for the expectation to be fulfilled (timeout: 5 seconds)
        wait(for: [expectation], timeout: 5)
    }

    // Test fetching users with a successful response
    func testFetchUsers_Success() async {
        // Arrange
        let expectedUsers = [
            User(login: "user1", id: 1, nodeID: "node1", avatarURL: "avatar1", gravatarID: "gravatar1", url: "url1", htmlURL: "html1", followersURL: "followers1", followingURL: "following1", gistsURL: "gists1", starredURL: "starred1", subscriptionsURL: "subscriptions1", organizationsURL: "organizations1", reposURL: "repos1", eventsURL: "events1", receivedEventsURL: "receivedEvents1", type: .user, siteAdmin: true),
            User(login: "user2", id: 2, nodeID: "node2", avatarURL: "avatar2", gravatarID: "gravatar2", url: "url2", htmlURL: "html2", followersURL: "followers2", followingURL: "following2", gistsURL: "gists2", starredURL: "starred2", subscriptionsURL: "subscriptions2", organizationsURL: "organizations2", reposURL: "repos2", eventsURL: "events2", receivedEventsURL: "receivedEvents2", type: .user, siteAdmin: false)
        ]
        userViewModelMock.fetchUsers = { completion in
            completion(.success(expectedUsers))
        }

        // Act
        await userViewModelMock.fetchUsers { result in
            switch result {
            case .success(let users):
                // Assert that the fetched users match the expected users
                XCTAssertEqual(users, expectedUsers, "Fetched users should match the expected users")
            case .failure:
                XCTFail("Fetching users should not fail")
            }
        }
    }

    // Test fetching users with an empty response
    func testFetchUsers_EmptyResponse() async {
        // Arrange
        userViewModelMock.fetchUsers = { completion in
            completion(.success([]))
        }

        // Act
        await userViewModelMock.fetchUsers { result in
            switch result {
            case .success(let users):
                if let users = users {
                    XCTAssertTrue(users.isEmpty, "Fetched users array should be empty")
                }
            case .failure:
                XCTFail("Fetching users should not fail")
            }
        }
    }

    // Test handling a failure with a network error
    func testHandleFailure_NetworkError() {
        // Arrange
        let expectedError = APIError.networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
        userViewModelMock.handleFailure = { completion, error in
            // Simulate handling the failure by calling the completion block
            completion(.failure(expectedError))
        }

        // Act
        userViewModelMock.handleFailure(completion: { result in
            switch result {
            case .success:
                XCTFail("Handling failure should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, expectedError, "Error should match the expected error")
            }
        }, error: expectedError)
    }

    // Test handling a failure with a decoding error
    func testHandleFailure_DecodingError() {
        // Arrange
        let expectedError = APIError.decodingError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
        userViewModelMock.handleFailure = { completion, error in
            // Simulate handling the failure by calling the completion block
            completion(.failure(expectedError))
        }

        // Act
        userViewModelMock.handleFailure(completion: { result in
            switch result {
            case .success:
                XCTFail("Handling failure should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, expectedError, "Error should match the expected error")
            }
        }, error: expectedError)
    }

    // Test fetching users with a network error
    func testFetchUsers_NetworkError() async {
        // Arrange
        let expectedError = APIError.networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
        userViewModelMock.fetchUsers = { completion in
            completion(.failure(expectedError))
        }

        // Act
        await userViewModelMock.fetchUsers { result in
            switch result {
            case .success:
                XCTFail("Fetching users should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, expectedError, "Error should match the expected network error")
            }
        }
    }

    // Test fetching users with a decoding error
    func testFetchUsers_DecodingError() async {
        // Arrange
        let expectedError = APIError.decodingError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
        userViewModelMock.fetchUsers = { completion in
            completion(.failure(expectedError))
        }

        // Act
        await userViewModelMock.fetchUsers { result in
            switch result {
            case .success:
                XCTFail("Fetching users should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, expectedError, "Error should match the expected decoding error")
            }
        }
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
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Fetch users expectation")

        // Set up the UserViewModelDelegateMock with an empty user list
        let userViewModelMock = userViewModel as! UserViewModelDelegateMock
        userViewModelMock.users = []
        
        // Define the behavior of the fetchUsers mock
        userViewModelMock.fetchUsers = { completion in
            completion(.success([]))
        }
        
        // Perform the fetchUsers operation and wait for completion
        await userViewModelMock.fetchUsers { result in
            switch result {
            case .success(let users):
                // Assert that the user list is empty
                XCTAssertEqual(users?.count, 0, "User list should be empty")
                
                // Assert that the numberOfRows in the HomeViewModel is also 0
                XCTAssertEqual(self.homeViewModel.numberOfRows, 0, "numberOfRows should be 0")
                
            case .failure:
                // Simulate handling the failure (You can add specific assertions here)
                userViewModelMock.handleFailure(completion: { result in
                    // You can add assertions related to error handling here if needed
                    NSError(domain: "TestDomain", code: 42, userInfo: nil)
                    XCTFail("Should not fail")
                }, error: .networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil)))
            }
            
            // Fulfill the expectation to indicate completion
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled (timeout: 5 seconds)
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testFetchUsers() async {
        let expectation = XCTestExpectation(description: "Fetch users expectation")
        
        await homeViewModel.fetchUsers { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users?.count, 2)
            case .failure:
                
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testFetchData() async {
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Fetch Data expectation")
        
        // Set up the UserViewModelDelegateMock
        let userViewModelMock = userViewModel as! UserViewModelDelegateMock
        
        // Define a sample user data to be returned by the service
        let sampleUsers: [User] = [
           User(login: "user1", id: 1, nodeID: "node1", avatarURL: "avatar1", gravatarID: "gravatar1", url: "url1", htmlURL: "html1", followersURL: "followers1", followingURL: "following1", gistsURL: "gists1", starredURL: "starred1", subscriptionsURL: "subscriptions1", organizationsURL: "organizations1", reposURL: "repos1", eventsURL: "events1", receivedEventsURL: "receivedEvents1", type: .user, siteAdmin: true),
            User(login: "user2", id: 2, nodeID: "node2", avatarURL: "avatar2", gravatarID: "gravatar2", url: "url2", htmlURL: "html2", followersURL: "followers2", followingURL: "following2", gistsURL: "gists2", starredURL: "starred2", subscriptionsURL: "subscriptions2", organizationsURL: "organizations2", reposURL: "repos2", eventsURL: "events2", receivedEventsURL: "receivedEvents2", type: .user, siteAdmin: false)
        ]
        
        // Define the behavior of the fetchUsers mock in the UserServices
        userViewModelMock.fetchUsers = { completion in
            completion(.success(sampleUsers))
        }
        
        // Call the fetchData method and wait for completion
       
        await (userViewModelMock as! UserViewModelDelegateMock).fetchData(service: UserServices()) { result in
            switch result {
            case .success(let users):
                // Assert that the users have been updated in the UserViewModel
                userViewModelMock.fetchUsers = { completion in
                    completion(.success(sampleUsers))
                }
                userViewModelMock.users = users ?? []
                XCTAssertEqual(userViewModelMock.users, sampleUsers, "Users should match the sample data")
                
                // Assert that the completion result matches the sample data
                XCTAssertEqual(users, sampleUsers, "Completion result should match the sample data")
                
            case .failure:
                // Simulate handling the failure (You can add specific assertions here)
                userViewModelMock.handleFailure(completion: { result in
                    // You can add assertions related to error handling here if needed
                }, error: .networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil)))
            }
            
            // Fulfill the expectation to indicate completion
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled (timeout: 5 seconds)
        await fulfillment(of: [expectation], timeout: 5)
    }

    
    func testHandleFailure()  {
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Handle Failure expectation")
        
        // Set up the UserViewModelDelegateMock
        let userViewModelMock = userViewModel as! UserViewModelDelegateMock
        
        // Define the behavior of the handleFailure mock
        let expectedError = APIError.networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
        
        // Use the typealias for the closure
        userViewModelMock.handleFailure = { completion, error in
            // Assert that the provided error matches the expected error
            XCTAssertEqual(error, expectedError, "Error should match the expected error")
            // Simulate handling the failure by calling the completion block
            completion(.failure(expectedError)) // Pass the expectedError
        }
        
        // Perform the handleFailure operation and wait for completion
        userViewModelMock.handleFailure(completion: { result in
            // You can add assertions related to error handling here if needed
        }, error:  expectedError)
        // Call the handleFailure method directly
    }
    
    
    
    func testEmptyOutletList() async {
        // Create an expectation to wait for the async completion
        let expectation = XCTestExpectation(description: "Fetch outlets expectation")
        
        // Set up the OutletViewModelDelegateMock with an empty outlet
        let emptyOutlet: Outlet? = nil
        let outletViewModelMock = outletViewModel as! OutletViewModelDelegateMock
        outletViewModelMock.outlet = emptyOutlet
        
        // Define the behavior of the fetchOutlets mock
        outletViewModelMock.fetchOutlets = { completion in
            completion(.success(emptyOutlet))
        }
        
        // Perform the fetchOutlets operation and wait for completion
        await outletViewModelMock.fetchOutlets { result in
            switch result {
            case .success(let outlet):
                // Assert that the outlet is nil (empty)
                XCTAssertNil(outlet, "Outlet should be nil (empty)")
            case .failure:
                // Simulate handling the failure (You can add specific assertions here)
                outletViewModelMock.handleFailure(completion: { result in
                    // You can add assertions related to error handling here if needed
                }, error: .networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil)))
            }
            
            // Fulfill the expectation to indicate completion
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled (timeout: 5 seconds)
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

import XCTest

class APIErrorHelperTests: XCTestCase {
    
    func testHandleAPIError() {
        // Create an expectation for the async completion
        let expectation = XCTestExpectation(description: "API error handled")
        
        // When
        
        APIErrorHelper.handleAPIError(completion: { (result: Result<String, APIError>) in
            switch result {
            case .failure(let receivedError):
                let expectedError: APIError = .networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil))
                XCTAssertEqual(receivedError, expectedError, "Received error should match the expected error")
            case .success:
                XCTFail("Expected a failure result, but got success")
            }
            expectation.fulfill()
        }, error: .networkError(NSError(domain: "TestDomain", code: 42, userInfo: nil))) // Use .networkError here
        
        wait(for: [expectation], timeout: 5.0)
    }

}

import XCTest

class OutletTests: XCTestCase {
    
    func testOutletEquality() {
        // Create two Outlet instances with the same property values
        let outlet1 = Outlet(
            page: 1,
            perPage: 10,
            total: 100,
            totalPages: 5,
            data: [Datum(city: "City1", name: "Outlet1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1)]
        )
        
        let outlet2 = Outlet(
            page: 1,
            perPage: 10,
            total: 100,
            totalPages: 5,
            data: [Datum(city: "City1", name: "Outlet1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1)]
        )
        
        // Assert that the two Outlet instances are equal
        XCTAssertEqual(outlet1, outlet2, "Outlet instances should be equal")
    }
    
    func testOutletInequality() {
        // Create two Outlet instances with different property values
        let outlet1 = Outlet(
            page: 1,
            perPage: 10,
            total: 100,
            totalPages: 5,
            data: [Datum(city: "City1", name: "Outlet1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1)]
        )
        
        let outlet2 = Outlet(
            page: 2, // Different page value
            perPage: 10,
            total: 100,
            totalPages: 5,
            data: [Datum(city: "City1", name: "Outlet1", estimatedCost: 50, userRating: UserRating(averageRating: 4.5, votes: 100), id: 1)]
        )
        
        // Assert that the two Outlet instances are not equal
        XCTAssertNotEqual(outlet1, outlet2, "Outlet instances should not be equal")
    }
}

import NetworkReachability
import XCTest
import Foundation
import NetworkReachability

class RequestHandlerMock: RequestHandlerProtocol {
    var mockRequestDataResult: Result<Data, APIError>?

    func requestData(url: URL, completion: @escaping RequestCompletion<Data>) {
        if let result = mockRequestDataResult {
            completion(result)
        }
    }
}

class ResponseHandlerMock: ResponseHandlerProtocol {
    var mockParseModelsResult: Result<String, APIError>?

    func parseModels<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>) {
        if let result = mockParseModelsResult as? Result<T, APIError> {
            completion(result)
        }
    }
}

import XCTest
import Foundation
import NetworkReachability


class NetworkReachabilityManagerMock: NetworkReachabilityManagerProtocol {
    var networkPath: NetworkMonitor

    init() {
        // Create a NetworkMonitor object and set its status
        let networkMonitor = NetworkMonitor()
        self.networkPath = networkMonitor
    }
}



class ApiManagerTests: XCTestCase {
    var apiManager: ApiManager!

    override func setUp() {
        super.setUp()
        let networkReachabilityManagerMock = NetworkMonitor()
        let requestHandlerMock = RequestHandlerMock()
        let responseHandlerMock = ResponseHandlerMock()
        apiManager = ApiManager(
            networkReachabilityManager: networkReachabilityManagerMock,
            reqHandler: requestHandlerMock,
            responseHandler: responseHandlerMock
        )
    }

    // MARK: - Test Cases

    // Test a successful API request
    func testRequest_Success() async {
        // Arrange
        let url = URL(string: "https://example.com")!
        let responseData = Data("Mock Response Data".utf8)

        let requestHandlerMock = apiManager.reqHandler as! RequestHandlerMock
        requestHandlerMock.mockRequestDataResult = .success(responseData)

        let responseHandlerMock = apiManager.responseHandler as! ResponseHandlerMock
        responseHandlerMock.mockParseModelsResult = .success("Mock Response Data")

        let expectation = XCTestExpectation(description: "Request completed")

        // Act
        await apiManager.request(urlString: url.absoluteString) { (result: Result<String, APIError>) in
            // Assert
            switch result {
            case .success(let response):
                XCTAssertEqual(response, "Mock Response Data", "Response should match the expected data")
            case .failure(let error):
                XCTFail("Request should not fail. Error: \(error)")
            }
            expectation.fulfill()
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 1.0)
    }

}

class RequestHandlerTests: XCTestCase {
    var requestHandler: RequestHandler!

    override func setUp() {
        super.setUp()
        requestHandler = RequestHandler()
    }

    // MARK: - Test Cases

    // Test sending a request with a valid URL
    func testRequestWithValidURL() {
        // Arrange
        let url = URL(string: "https://example.com")!
        let expectation = XCTestExpectation(description: "Request completed")

        // Act
        requestHandler.requestData(url: url) { (result: Result<Data, APIError>) in
            // Assert
            switch result {
            case .success:
                // The request should succeed for a valid URL
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Request should not fail. Error: \(error)")
            }
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }

    // Test sending a request with an invalid URL
    func testRequestWithInvalidURL() {
        // Arrange
        let invalidURL = URL(string: "invalid-url")!
        let expectation = XCTestExpectation(description: "Request completed")

        // Act
        requestHandler.requestData(url: invalidURL) { (result: Result<Data, APIError>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Request should fail for an invalid URL")
            case .failure(let error):
                // The request should fail with a network error for an invalid URL
                if case APIError.networkError = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Request should fail with a network error. Error: \(error)")
                }
            }
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }
}

class ResponseHandlerTests: XCTestCase {
    var responseHandler: ResponseHandler!

    override func setUp() {
        super.setUp()
        responseHandler = ResponseHandler()
    }

    // MARK: - Test Cases

    // Test parsing a valid JSON response
    func testParseValidJSONResponse() {
        // Arrange
        let jsonData = """
        {
            "login": "John",
            "id": 30
        }
        """.data(using: .utf8)!
        let expectation = XCTestExpectation(description: "Parsing completed")

        // Act
        responseHandler.parseModels(data: jsonData) { (result: Result<User, APIError>) in
            // Assert
            switch result {
            case .success(let user):
                XCTAssertEqual(user.login, "John", "Parsed user's name should match the expected value")
                XCTAssertEqual(user.id, 30, "Parsed user's age should match the expected value")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Parsing should not fail. Error: \(error)")
            }
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }

    // Test parsing an invalid JSON response
    func testParseInvalidJSONResponse() {
        // Arrange
        let invalidJSONData = Data("Invalid JSON".utf8)
        let expectation = XCTestExpectation(description: "Parsing completed")

        // Act
        responseHandler.parseModels(data: invalidJSONData) { (result: Result<User, APIError>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Parsing should fail for invalid JSON data")
            case .failure(let error):
                // The parsing should fail with a decoding error for invalid JSON
                if case APIError.decodingError = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Parsing should fail with a decoding error. Error: \(error)")
                }
            }
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }
}


