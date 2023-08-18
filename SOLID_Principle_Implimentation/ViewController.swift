//
//  ViewController.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 18/08/2023.
//

import UIKit

class ViewController: UIViewController {
let urlString = "https://jsonmock.hackerrank.com/api/food_outlets?city=seattle&page=1"
  override func viewDidLoad() {
    super.viewDidLoad()
     
    ApiManager().callApi(urlString: urlString, responseType: Outlet.self) { (apiResponse, error) in
      if let error = error {
        print("Error: \(error)")
      } else if let apiResponse = apiResponse {
          // Handle the parsed ApiResponse<Outlets> here
        print("API Response: \(apiResponse)")
        
          // Access individual properties of the response
        print("Page: \(apiResponse.page)")
        print("Total Pages: \(apiResponse.totalPages)")
        print("Data: \(apiResponse.data)")
        
          // Access properties of the Outlet objects
        for outlet in apiResponse.data {
          print("Outlet ID: \(outlet.id)")
          print("Outlet Name: \(outlet.name)")
          print("Outlet City: \(outlet.city)")
          print("Outlet Estimated Cost: \(outlet.estimatedCost)")
          print("Outlet User Rating: \(outlet.userRating)")
        }
      }
    }

  }

}

