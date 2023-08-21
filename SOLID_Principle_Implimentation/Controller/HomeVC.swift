  //
  //  ViewController.swift
  //  SOLID_Principle_Implimentation
  //
  //  Created by KamsQue on 18/08/2023.
  //
import SOLID_Principle_Implimentation
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


class HomeVC: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var vm: HomeViewModelDelegate!
  let userViewModel = UserViewModel() // Create an instance of UserViewModelDelegate
  let outletViewModel = OutletViewModel() // Create an instance of OutletViewModelDelegate
  
  init(vm:HomeViewModelDelegate) {
      // Create an instance of HomeViewModel using the created instances
    self.vm = HomeViewModel(userViewModel: userViewModel, outletViewModel: outletViewModel)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.vm = HomeViewModel(userViewModel: userViewModel, outletViewModel: outletViewModel)
    setupTableView()
    fetchData()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  private func fetchData() {
    showSpinner()
    Task.detached {
      await self.fetchUsers()
      await self.fetchOutlets()
      await self.hideSpinner()
    }
  }
}

extension HomeVC: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    
    return vm.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return vm.numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let cellViewModel = vm.cellViewModel(for: indexPath)
    cell.textLabel?.text = cellViewModel.user.login
    return cell
  }
}

extension HomeVC: UITableViewDelegate {
    // Implement UITableViewDelegate methods as needed
}

extension HomeVC {
  
  private func fetchUsers() async {
    view.showSpinner()
    await vm.fetchUsers { [weak self] result in
      switch result {
      case .success(_):
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      case .failure(let error):
        self?.handleError(error)
      }
    }
  }
  
  func fetchOutlets() async{
    view.showSpinner()
    await vm.fetchOutlets { [weak self] result in
      switch result {
      case .success(_):
        DispatchQueue.main.async {
          self?.view.hideSpinner()
        }
      case .failure(let error):
        self?.handleError(error)
      }
    }
  }
  
  private func handleError(_ error: APIError) {
    DispatchQueue.global().async { [weak self] in
      DispatchQueue.main.async {
        self?.hideSpinner()
        self?.showAlert(type: .error, title: "Error", message: error.localizedDescription, autoDismissTimer: 1.0)
      }
    }
  }
}

  // Create a separate extension for UI-related tasks
extension HomeVC {
  private func showSpinner() {
    view.showSpinner()
  }
  
  private func hideSpinner() {
    view.hideSpinner()
  }
  
  private func showAlert(type: UIView.AlertType, title: String?, message: String?, autoDismissTimer: TimeInterval? = nil) {
      // Show alert logic
    view.showAlert(type: type, title: title, message: message, imagePosition : .top, autoDismissTimer: autoDismissTimer)
  }
}
