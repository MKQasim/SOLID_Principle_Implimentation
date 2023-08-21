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
}
  // MARK: - Datum
struct Datum: Codable {
  let city: String
  let name: String
  let estimatedCost: Int
  let userRating: UserRating
  let id: Int
}

  // MARK: - UserRating
struct UserRating: Codable {
  let averageRating: Double
  let votes: Int
}


extension Outlet: Equatable {
  static func == (lhs: Outlet, rhs: Outlet) -> Bool {
      // Compare the properties of lhs and rhs here
    return lhs.page == rhs.page &&
    lhs.perPage == rhs.perPage &&
    lhs.total == rhs.total &&
    lhs.totalPages == rhs.totalPages
//    lhs.data == rhs.data
  }
}
