//
//  ReachabilityManager.swift
//  SOLID_Principle_Implimentation
//
//  Created by KamsQue on 19/08/2023.
//

import Network
import NetworkReachability

  // Define an enum for the network status
enum NetworkStatus: CustomStringConvertible {
  case satisfied
  case unsatisfied
  case requiresConnection
  case unknown
  
    // Provide a custom description for each case
  var description: String {
    switch self {
    case .satisfied:
      return "Network is available"
    case .unsatisfied:
      return "Network is unavailable"
    case .requiresConnection:
      return "Network requires connection"
    case .unknown:
      return "Network status is unknown"
    }
  }
}

  // Define a protocol for the network reachability delegate
protocol NetworkReachabilityDelegate: AnyObject {
  func networkReachabilityDidUpdate(_ status: NetworkStatus)
}

  // Define a class for the network reachability manager
class NetworkReachabilityManager {
  
    // Use a constant for the network monitor property
  let networkMonitor: NetworkMonitor
  
    // Use dependency injection to pass the network monitor object
  init(networkMonitor: NetworkMonitor) {
    self.networkMonitor = networkMonitor
      // Set the delegate of the network monitor to self
    self.networkMonitor.delegate = self
  }
  
    // Use a weak reference for the delegate property to avoid retain cycles
  weak var delegate: NetworkReachabilityDelegate?
}

  // Conform to the network monitor delegate protocol
extension NetworkReachabilityManager: NetworkMonitorDelegate {
  
  func networkMonitor(_ monitor: NetworkMonitor, didUpdateNetworkPath networkPath: NWPath) {
      // Use a switch statement to handle the different cases of the network status
    switch networkPath.status {
    case .satisfied:
      delegate?.networkReachabilityDidUpdate(.satisfied)
    case .unsatisfied:
      delegate?.networkReachabilityDidUpdate(.unsatisfied)
    case .requiresConnection:
      delegate?.networkReachabilityDidUpdate(.requiresConnection)
    default:
      delegate?.networkReachabilityDidUpdate(.unknown)
    }
  }
}
