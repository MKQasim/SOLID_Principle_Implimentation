//
//  ViewExtension.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 03/09/2023.
//

import Foundation

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
