//
//  LoginView.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit
import FirebaseAuth

protocol LoginRegisterViewDelegate: NSObjectProtocol {
    func shouldDismissKeyboard()
    func invalidFormSubmitted()
    func successfulLoginOrRegister(email: String, password: String)
}

class LoginView: UIView {
    let kNibName = "LoginView"
    @IBOutlet weak var emailAddressTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!

    weak var delegate: LoginRegisterViewDelegate?
    
    let viewModel = LoginViewViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit(kNibName)
        initialSetup()
        setupDelegates()
    }
    
    func resetView() {
        initialSetup()
    }
    
    fileprivate func initialSetup() {
        emailAddressTextBox.layer.borderWidth = viewModel.textFieldBorderWidth
        emailAddressTextBox.layer.cornerRadius = viewModel.textFieldBorderRadius
        emailAddressTextBox.layer.borderColor = viewModel.textFieldBorderColor
        passwordTextBox.layer.borderWidth = viewModel.textFieldBorderWidth
        passwordTextBox.layer.cornerRadius = viewModel.textFieldBorderRadius
        passwordTextBox.layer.borderColor = viewModel.textFieldBorderColor
        emailAddressTextBox.text = nil
        passwordTextBox.text = nil
    }
    
    fileprivate func setupDelegates() {
        emailAddressTextBox.delegate = self
        passwordTextBox.delegate = self
        emailAddressTextBox.addTarget(self, action: #selector(emailAddressChange), for: .editingChanged)
        passwordTextBox.addTarget(self, action: #selector(passwordChange), for: .editingChanged)
    }
    
    @objc func emailAddressChange() {
        let emailText = emailAddressTextBox.text
        guard let email = emailText else { return }
        emailAddressTextBox.layer.borderColor = viewModel.getEmailBorderColor(forString: email)
    }
    
    @objc func passwordChange() {
        let passwordText = passwordTextBox.text
        guard let password = passwordText else { return }
        passwordTextBox.layer.borderColor = viewModel.getPasswordBorderColor(forString: password)
    }
    
    @IBAction func onTapLoginButton(_ sender: Any) {
        delegate?.shouldDismissKeyboard()
        passwordChange()
        emailAddressChange()
        guard let email = emailAddressTextBox.text,
              let password = passwordTextBox.text,
              viewModel.isEmailValid(email) else {
            delegate?.invalidFormSubmitted()
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let result = authResult, error == nil else {
                debugPrint("Login Error")
                self?.delegate?.invalidFormSubmitted()
                return
            }
            debugPrint(result)
            self?.delegate?.successfulLoginOrRegister(email: email, password: password)
        }
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailAddressTextBox.isFirstResponder {
            passwordTextBox.becomeFirstResponder()
        } else if passwordTextBox.isFirstResponder {
            onTapLoginButton(self)
        }
        return true
    }
}
