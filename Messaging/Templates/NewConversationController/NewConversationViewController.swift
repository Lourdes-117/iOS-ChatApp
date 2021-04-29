//
//  NewConversationViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/27/21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    static let kIdentifier = "NewConversationViewController"
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var users = [[String: String]]()
    private var searchResults = [[String: String]]()
    private var hasFetched = false
    
    let viewModel = NewConversationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] results in
                switch results {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    debugPrint(error)
                }
                self?.hasFetched = true
                self?.filterUsers(with: query)
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard hasFetched else { return }
        self.spinner.dismiss()
        let results: [[String: String]] = self.users.filter({
            guard let name = $0[StringConstants.shared.database.name]?.lowercased() else { return false }
            return name.hasPrefix(term)
        })
        
        self.searchResults = results
        
        self.tableView.reloadData()
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        self.spinner.show(in: view)
        searchResults.removeAll()
        hasFetched = false
        searchUsers(query: text.lowercased())
    }
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeConversationTableViewCell.kIdentifier) as? HomeConversationTableViewCell else { return UITableViewCell() }
        
        cell.cellTitle = searchResults[indexPath.row][StringConstants.shared.database.name]
        return cell
    }
}

extension NewConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
