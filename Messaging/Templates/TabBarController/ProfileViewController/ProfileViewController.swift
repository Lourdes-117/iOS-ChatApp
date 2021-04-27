//
//  ProfileViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    let kIdentifier = "ProfileViewController"
    
    let viewModel = ProfileViewControllerViewModel()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        self.title = viewModel.screenTitle
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        registerCells()
        setupDataSourceAndDelegate()
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: HomeConversationTableViewCell.kIdentifier, bundle: nil), forCellReuseIdentifier: HomeConversationTableViewCell.kIdentifier)
    }
    
    fileprivate func setupDataSourceAndDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}


extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeConversationTableViewCell.kIdentifier) as? HomeConversationTableViewCell else { return UITableViewCell() }
        cell.accessoryType = .none
        cell.cellTitle = "Sign Out"
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            
            UIView.animate(withDuration: kAnimationDuration*5) { [weak self] in
                self?.view.alpha = 0
            } completion: { (_) in
                guard let window = UIApplication.shared.windows.first else { return }
                let mainStoryBoard = UIStoryboard(name: LoginViewController.kIdentifier, bundle: nil)
                let viewController = mainStoryBoard.instantiateViewController(withIdentifier: LoginViewController.kIdentifier)
                viewController.view.alpha = 0
                window.rootViewController = viewController
                UIView.animate(withDuration: kAnimationDuration*5) {
                    viewController.view.alpha = 1
                }
            }
        } catch {
            debugPrint("Error Signing Out")
        }
    }
}
