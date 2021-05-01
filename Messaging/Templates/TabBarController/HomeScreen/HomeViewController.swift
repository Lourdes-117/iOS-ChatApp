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
    
    var conversations: [Conversation] = [Conversation]()
    
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
        startListeningForConversations()
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
    
    fileprivate func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email) as? String else {
            signOutUserAndForceCloseApp()
            return
        }
        DatabaseManager.shared.getAllConversations(for: email) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else { return }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                debugPrint("Failed To Get Convos \(error)")
            }
        }
    }
    
    fileprivate func openChatWithUser(name: String, email: String, conversationID: String?) {
        guard let chatViewController = ChatViewController.initiateVC() else { return }
        
        chatViewController.setupConversation(name: name, email: email, isNewConversation: true, conversationID: conversationID)
        chatViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeConversationTableViewCell.kIdentifier) as? HomeConversationTableViewCell else { return UITableViewCell() }
        let name = conversations[indexPath.row].name
        let message = conversations[indexPath.row].latestMessage.text
        let email = conversations[indexPath.row].otherUserEmail
        cell.setupCell(userName: name, latestMessage: message, email: email)
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
        let name = conversations[indexPath.row].name
        let email = conversations[indexPath.row].otherUserEmail
        let conversationID = conversations[indexPath.row].id
        openChatWithUser(name: name, email: email, conversationID: conversationID)
    }
}

extension HomeViewController: NewConversationDelegate {
    func startNewConversationWith(name: String, email: String) {
        openChatWithUser(name: name, email: email, conversationID: nil)
    }
}
