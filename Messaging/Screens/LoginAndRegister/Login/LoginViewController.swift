//
//  LoginViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//

import UIKit

class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginView: LoginView!
    
    let viewModel = LoginControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        initialSetup()
    }
    
    fileprivate func setupDelegates() {
        loginView.delegate = self
    }
    
    fileprivate func initialSetup() {
        title = viewModel.loginTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.registerTitle, style: .done, target: self, action: #selector(onTapRegisterButton))
        imageViewWidthConstraint.constant = view.frame.width/3
    }
    
    @objc func onTapRegisterButton() {
        viewModel.isOnLoginPage.toggle()
        if viewModel.isOnLoginPage {
            title = viewModel.loginTitle
        } else {
            title = viewModel.registerTitle
        }
    }
    
    func presentInvalidFormAlert() {
        let alert = UIAlertController(title: viewModel.formInvalidAlertTitle, message: viewModel.formInvalidAlertMessage , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: viewModel.alertDismissMessage, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: LoginViewDelegate {
    func shouldDismissKeyboard() {
        self.dismissKeyboard()
    }
    
    func invalidFormSubmitted() {
        self.presentInvalidFormAlert()
    }
}
