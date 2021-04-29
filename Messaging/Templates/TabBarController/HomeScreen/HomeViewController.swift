//
//  ViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//

import UIKit
import FirebaseAuth

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: HomeConversationTableViewCell.kIdentifier, bundle: nil),
                           forCellReuseIdentifier: HomeConversationTableViewCell.kIdentifier)
    }
    
    private func setupDataSourceDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func didTapComposeButton() {
        let chatStoryboard = UIStoryboard(name: NewConversationViewController.kIdentifier, bundle: nil)
        let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: NewConversationViewController.kIdentifier)
        let navController = UINavigationController(rootViewController: chatViewController)
        present(navController, animated: true, completion: nil)
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
        
        let chatStoryboard = UIStoryboard(name: ChatViewController.kIdentifier, bundle: nil)
        let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: ChatViewController.kIdentifier)
    
        chatViewController.title = "Some User"
        chatViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
