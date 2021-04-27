//
//  NewConversationViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/27/21.
//

import UIKit
import FirebaseAuth

class NewConversationViewController: UIViewController {
    static let kIdentifier = "NewConversationViewController"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = NewConversationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do { try FirebaseAuth.Auth.auth().signOut() } catch{  }
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        searchBar.becomeFirstResponder()
        self.title = viewModel.screenTitle
        registerCells()
        setupDataSourceDelegate()
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: HomeConversationTableViewCell.kIdentifier, bundle: nil),
                           forCellReuseIdentifier: HomeConversationTableViewCell.kIdentifier)
    }
    
    fileprivate func setupDataSourceDelegate() {
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}

extension NewConversationViewController: UITableViewDelegate {
    
}
