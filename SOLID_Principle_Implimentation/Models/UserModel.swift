//
//  UserModel.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 19/08/2023.
//

import Foundation

typealias Users = [User]
  // MARK: - User
struct User: Codable , Equatable{
  let login: String
  let id: Int
  let nodeID: String?
  let avatarURL: String?
  let gravatarID: String?
  let url, htmlURL, followersURL: String?
  let followingURL, gistsURL, starredURL: String?
  let subscriptionsURL, organizationsURL, reposURL: String?
  let eventsURL: String?
  let receivedEventsURL: String?
  let type: TypeEnum
  let siteAdmin: Bool?
  
  enum CodingKeys: String, CodingKey {
    case login, id
    case nodeID
    case avatarURL
    case gravatarID
    case url
    case htmlURL
    case followersURL
    case followingURL
    case gistsURL
    case starredURL
    case subscriptionsURL
    case organizationsURL
    case reposURL
    case eventsURL
    case receivedEventsURL
    case type
    case siteAdmin
  }
}

enum TypeEnum: String, Codable {
  case organization = "Organization"
  case user = "User"
}



