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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    private func initialSetup() {
        self.title = "Chats"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        registerCells()
        setupDataSourceDelegate()
    }
    
    private func registerCells() {
        
    }
    
    private func setupDataSourceDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatStoryboard = UIStoryboard(name: ChatViewController.kIdentifier, bundle: nil)
        let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: ChatViewController.kIdentifier)
    
        chatViewController.title = "Some Name"
        chatViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
