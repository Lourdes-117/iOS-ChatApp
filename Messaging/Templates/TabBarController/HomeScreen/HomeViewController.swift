//
//  ViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//

import UIKit
import FirebaseAuth

protocol NewConversationDelegate: NSObjectProtocol {
    func startNewConversationWith(name: String, email: String)
}

class HomeViewController: UIViewController {
    static let kIdentifier = "HomeViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = HomeScreenViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    private func initialSetup() {
        self.title = viewModel.screenTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        addNewConversationButton()
        registerCells()
        setupDataSourceDelegate()
    }
    
    private func addNewConversationButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapNewConversationButton))
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: HomeConversationTableViewCell.kIdentifier, bundle: nil),
                           forCellReuseIdentifier: HomeConversationTableViewCell.kIdentifier)
    }
    
    private func setupDataSourceDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func didTapNewConversationButton() {
        guard let chatViewController = NewConversationViewController.initiateVC() else { return }
        chatViewController.delegate = self
        let navController = UINavigationController(rootViewController: chatViewController)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func openChatWithUser(name: String, email: String) {
        guard let chatViewController = ChatViewController.initiateVC() else { return }
        
        chatViewController.setUser(name: name, email: email, isNewConversation: true)
        chatViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeConversationTableViewCell.kIdentifier) as? HomeConversationTableViewCell else { return UITableViewCell() }
        cell.cellTitle = "Some User"
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openChatWithUser(name: "Some User", email: "email@gmaill.com")
    }
}

extension HomeViewController: NewConversationDelegate {
    func startNewConversationWith(name: String, email: String) {
        openChatWithUser(name: name, email: email)
    }
}
