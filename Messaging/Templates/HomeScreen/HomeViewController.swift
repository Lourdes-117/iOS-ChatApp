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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTapSignout(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch {
            debugPrint("Error Signing Out")
        }
    }
}
