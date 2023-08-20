  //
  //  NetworkManager.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //

import Foundation
import NetworkReachability


  // MARK: - API Error
enum APIError: Error {
  case networkError(Error)
  case decodingError(Error)
  case noDataError(Error)
}

  // Type Aliases
typealias APICompletion<Data> = (Result<Data, APIError>) -> Void
typealias ResponseCompletion<T> = (Result<T, APIError>) -> Void
typealias APIRequest<T> = (Result<T, APIError>) -> Void


class ApiManager {
  let apiHandler: APIHandler
  let responseHandler: ResponseHandler
  let networkReachabilityManager: NetworkReachabilityManager
  
  init(networkReachabilityManager: NetworkReachabilityManager = NetworkReachabilityManager(networkMonitor: NetworkMonitor()) ,apiHandler: APIHandler = APIHandler(), responseHandler: ResponseHandler = ResponseHandler()) {
    self.networkReachabilityManager = networkReachabilityManager
    self.apiHandler = apiHandler
    self.responseHandler = responseHandler
  }
  
  func request<T: Codable>(urlString: String, completion: @escaping APIRequest<T>) async {
      // Check the network status before making the request
    switch await NetworkMonitor.networkPath.status {
    case .satisfied:
        // If the network is available, proceed with the request
      if let url = URL(string: urlString) {
        apiHandler.requestData(url: url) { result in
          switch result {
          case .success(let data):
            self.responseHandler.parseModels(data: data, completion: completion)
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
    case .unsatisfied, .requiresConnection:
        // If the network is unavailable or requires connection, return an error
      completion(.failure(.networkError(NSError(domain: "Network Error", code: 0, userInfo: nil))))
    default:
        // If the network status is unknown, return an error
      completion(.failure(.networkError(NSError(domain: "Unknown Network Error", code: 0, userInfo: nil))))
    }
  }

}

class APIHandler {
  func requestData(url: URL, completion: @escaping APICompletion<Data>) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(.networkError(error)))
        return
      }
      
      guard let data = data else {
        completion(.failure(.noDataError(NSError(domain: "No Data Error", code: 0, userInfo: nil))))
        return
      }
      
      completion(.success(data))
    }.resume()
  }
}

class ResponseHandler {
  func parseModels<T: Codable>(data: Data, completion: @escaping ResponseCompletion<T>) {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    decoder.keyDecodingStrategy = .useDefaultKeys
//    if let rawDataString = String(data: data, encoding: .utf8) {
//      print("Raw Data: \(rawDataString)")
//    }
    do {
      let decodedResponse = try decoder.decode(T.self, from: data)
      completion(.success(decodedResponse))
    } catch {
      completion(.failure(.decodingError(error)))
    }
  }
}


import UIKit

extension UIView {
  private var spinnerTag: Int { return 999999 }
  
  func showSpinner() {
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.tag = spinnerTag
    spinner.translatesAutoresizingMaskIntoConstraints = false
    addSubview(spinner)
    
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    
    spinner.startAnimating()
    isUserInteractionEnabled = false
  }
  
  func hideSpinner() {
    if let spinner = viewWithTag(spinnerTag) as? UIActivityIndicatorView {
      spinner.stopAnimating()
      spinner.removeFromSuperview()
      isUserInteractionEnabled = true
    }
  }
}


import UIKit

extension UIView {
  private var alertTag: Int { return 999998 }
  
  func showAlert(type: AlertType, style: AlertStyle = .alert, title: String? = nil, titleFont: UIFont? = nil, titleFontSize: CGFloat? = nil, message: String? = nil, messageFont: UIFont? = nil, messageFontSize: CGFloat? = nil, cornerRadius: CGFloat? = nil, imagePosition: ImagePosition = .top, buttonsPosition: ButtonsPosition = .vertical, image: UIImage? = nil, buttons: [AlertButton]? = nil, autoDismissTimer: TimeInterval? = nil, completion: (() -> Void)? = nil) {
    var alertController: UIAlertController
    if style == .alert {
      alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    } else {
      alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    }
    
    if let cornerRadius = cornerRadius {
      alertController.view.layer.cornerRadius = cornerRadius
      alertController.view.clipsToBounds = true
    }
    
    if let image = image {
      let imageView = UIImageView(image: image)
      imageView.contentMode = .scaleAspectFit
      alertController.view.addSubview(imageView)
      
      imageView.translatesAutoresizingMaskIntoConstraints = false
      switch imagePosition {
      case .top:
        imageView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
      case .bottom:
        imageView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -20).isActive = true
      case .left:
        imageView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20).isActive = true
      case .right:
        imageView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20).isActive = true
      case .center:
        imageView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor).isActive = true
      }
      
      imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
      imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    if let buttons = buttons {
      for button in buttons {
        let action = UIAlertAction(title: button.title, style: .default) { _ in
          button.action?()
        }
        alertController.addAction(action)
      }
    }
    
    if autoDismissTimer != nil {
      let delay = DispatchTime.now() + autoDismissTimer!
      DispatchQueue.main.asyncAfter(deadline: delay) {
        alertController.dismiss(animated: true, completion: nil)
      }
    }
    
    if let titleFont = titleFont, let titleFontSize = titleFontSize {
      if let title = alertController.title {
        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: titleFont.withSize(titleFontSize)])
        alertController.setValue(attributedString, forKey: "attributedTitle")
      }
    }
    
    if let messageFont = messageFont, let messageFontSize = messageFontSize {
      if let message = alertController.message {
        let attributedString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font: messageFont.withSize(messageFontSize)])
        alertController.setValue(attributedString, forKey: "attributedMessage")
      }
    }
    
    DispatchQueue.main.async {
      if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
        if rootViewController.presentedViewController == nil {
          rootViewController.present(alertController, animated: true, completion: nil)
        } else {
          rootViewController.dismiss(animated: false) {
            rootViewController.present(alertController, animated: true, completion: nil)
          }
        }
      }
    }

  }
  
  enum AlertType {
    case success, error, info
    
    var image: UIImage {
      switch self {
      case .success:
        return UIImage(systemName: "checkmark.circle.fill")!
      case .error:
        return UIImage(systemName: "exclamationmark.circle.fill")!
      case .info:
        return UIImage(systemName: "info.circle.fill")!
      }
    }
  }
  
  enum AlertStyle {
    case alert, actionSheet
  }
  
  enum ImagePosition {
    case top, bottom, left, right, center
  }
  
  enum ButtonsPosition {
    case vertical, horizontal
  }
  
  struct AlertButton {
    let title: String
    let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)? = nil) {
      self.title = title
      self.action = action
    }
  }
}
