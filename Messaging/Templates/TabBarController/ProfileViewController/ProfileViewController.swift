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
        self.navigationController?.navigationBar.prefersLargeTitles = true
        registerCells()
        setupDataSourceAndDelegate()
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: ProfilePictureTableViewCell.kIdentifier, bundle: nil), forCellReuseIdentifier: ProfilePictureTableViewCell.kIdentifier)
        tableView.register(UINib(nibName: SignoutTableViewCell.kIdentifier, bundle: nil), forCellReuseIdentifier: SignoutTableViewCell.kIdentifier)
    }
    
    fileprivate func setupDataSourceAndDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}


extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileViewCells.none.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = ProfileViewCells(rawValue: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType?.getCellIdentifier() ?? "")
        switch cellType {
        case .SignOut:
            guard let cell = cell as? SignoutTableViewCell else { return UITableViewCell() }
            cell.cellTitle = viewModel.signOut
            return cell
            
        case .ProfilePic:
            guard let cell = cell as? ProfilePictureTableViewCell else { return UITableViewCell() }
            cell.setupCell()
            return cell
        default:
            debugPrint("All Cells Populated")
        }
        return cell ?? UITableViewCell()
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch ProfileViewCells(rawValue: indexPath.row) {
        case .SignOut:
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                
                UIView.animate(withDuration: kAnimationDuration*5) { [weak self] in
                    self?.view.alpha = 0
                    self?.navigationController?.view.alpha = 0
                    self?.tabBarController?.view.alpha = 0
                } completion: { (_) in
                    guard let window = UIApplication.shared.windows.first else { return }
                    let mainStoryBoard = UIStoryboard(name: LoginViewController.kIdentifier, bundle: nil)
                    let viewController = mainStoryBoard.instantiateViewController(withIdentifier: LoginViewController.kIdentifier)
                    let navController =  UINavigationController(rootViewController: viewController)
                    viewController.view.alpha = 0
                    window.rootViewController = navController
                    UIView.animate(withDuration: kAnimationDuration*5) {
                        viewController.view.alpha = 1
                    }
                }
            } catch {
                debugPrint("Error Signing Out")
            }
        default:
            debugPrint("Cell Tapped")
        }
    }
}
