//
//  OutletModel.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 19/08/2023.
//

import Foundation

  // MARK: - Outlet
struct Outlet: Codable {
  let page, perPage, total, totalPages: Int
  let data: [Datum]
  
  enum CodingKeys: String, CodingKey {
    case page
    case perPage
    case total
    case totalPages
    case data
  }
}
  // MARK: - Datum
struct Datum: Codable {
  let city: String
  let name: String
  let estimatedCost: Int
  let userRating: UserRating
  let id: Int
  
  enum CodingKeys: String, CodingKey {
    case city, name
    case estimatedCost
    case userRating
    case id
  }
}

  // MARK: - UserRating
struct UserRating: Codable {
  let averageRating: Double
  let votes: Int
  
  enum CodingKeys: String, CodingKey {
    case averageRating
    case votes
  }
}
  // MARK: - FoodOutletError
enum FoodOutletError: Error {
  case networkError(Error)
  case decodingError(Error)
  case noDataError(Error)
}

