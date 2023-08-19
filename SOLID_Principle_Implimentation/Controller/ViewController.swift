//
//  ViewController.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 18/08/2023.
//

import UIKit
  // MARK: - Step 1 Requirements to call Api

  // steps1: Check url is working
  // step2 : Check response json is valid
  // step3 : Create Models
  // step4 : Create Client API Manager ->
  // step5 : Create Progeess Loader start stop
  // step6 : Api Request Handler -> T
  // step7 : Api Response Handler -> T
  // step8 : Convert completion TypAalies -> T
  // step9 : Error Handling -> T


class ViewController: UIViewController {
  let apiManager = ApiManager()
  let apiUrlString = "https://jsonmock.hackerrank.com/api/food_outlets?city=seattle&page=1"
  override func viewDidLoad() {
    super.viewDidLoad()
    apiManager.request(urlString: apiUrlString) { (result: Result<Outlet, FoodOutletError>) in
      switch result {
      case .success(let outlets):
          // Handle the outlets data
        print(outlets)
      case .failure(let error):
          // Handle the error
        print("Error: \(error)")
      }
    }
  }
}





