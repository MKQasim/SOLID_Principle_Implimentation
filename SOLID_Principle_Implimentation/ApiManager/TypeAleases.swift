//
//  TypeAleases.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 21/08/2023.
//

import Foundation

  // Type Aliases for Completions
typealias UserCompletion = (Result<[User], APIError>) -> Void
typealias OutletCompletion = (Result<Outlet?, APIError>) -> Void
