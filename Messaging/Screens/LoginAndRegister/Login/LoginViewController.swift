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
    @IBOutlet weak var registerView: RegisterView!
    
    let viewModel = LoginControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupDelegates()
    }
    
    fileprivate func initialSetup() {
        loginView.isHidden = false
        registerView.isHidden = true
        title = viewModel.pageTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.pageTitle, style: .done, target: self, action: #selector(onTapLoginRegisterSwitchButton))
        imageViewWidthConstraint.constant = view.frame.width/3
    }
    
    fileprivate func setupDelegates() {
        loginView.delegate = self
    }
    
    @objc func onTapLoginRegisterSwitchButton() {
        self.dismissKeyboard()
        viewModel.isOnLoginPage.toggle()
        title = viewModel.pageTitle
        loginView.isHidden = viewModel.shouldHideLoginPage
        registerView.isHidden = viewModel.shouldHideRegisterPage
    }
    
    func presentInvalidFormAlert() {
        let alert = UIAlertController(title: viewModel.formInvalidAlertTitle, message: viewModel.formInvalidAlertMessage , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: viewModel.alertDismissMessage, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: LoginRegisterViewDelegate {
    func shouldDismissKeyboard() {
        self.dismissKeyboard()
    }
    
    func invalidFormSubmitted() {
        self.presentInvalidFormAlert()
    }
}
