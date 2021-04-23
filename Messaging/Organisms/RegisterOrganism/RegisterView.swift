//
//  RegisterView.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit

class RegisterView: UIView {
    let kNibName = "RegisterView"
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var secondNameField: UITextField!
    @IBOutlet weak var emailAddressTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    
    weak var delegate: LoginRegisterViewDelegate?
    
    let viewModel = RegisterViewViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit(kNibName)
        initialSetup()
        setupDelegates()
    }
    
    fileprivate func initialSetup() {
        firstNameField.layer.borderWidth = viewModel.textFieldBorderWidth
        firstNameField.layer.cornerRadius = viewModel.textFieldBorderRadius
        firstNameField.layer.borderColor = viewModel.textFieldBorderColor
        secondNameField.layer.borderWidth = viewModel.textFieldBorderWidth
        secondNameField.layer.cornerRadius = viewModel.textFieldBorderRadius
        secondNameField.layer.borderColor = viewModel.textFieldBorderColor
        emailAddressTextBox.layer.borderWidth = viewModel.textFieldBorderWidth
        emailAddressTextBox.layer.cornerRadius = viewModel.textFieldBorderRadius
        emailAddressTextBox.layer.borderColor = viewModel.textFieldBorderColor
        passwordTextBox.layer.borderWidth = viewModel.textFieldBorderWidth
        passwordTextBox.layer.cornerRadius = viewModel.textFieldBorderRadius
        passwordTextBox.layer.borderColor = viewModel.textFieldBorderColor
    }
    
    fileprivate func setupDelegates() {
        firstNameField.delegate = self
        secondNameField.delegate = self
        emailAddressTextBox.delegate = self
        passwordTextBox.delegate = self
        emailAddressTextBox.addTarget(self, action: #selector(emailAddressChange), for: .editingChanged)
        passwordTextBox.addTarget(self, action: #selector(passwordChange), for: .editingChanged)
        firstNameField.addTarget(self, action: #selector(nameChange(nameTextField:)), for: .editingChanged)
        secondNameField.addTarget(self, action: #selector(nameChange(nameTextField:)), for: .editingChanged)
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
    
    @objc func nameChange(nameTextField: UITextField) {
        guard let name = nameTextField.text else { return }
        nameTextField.layer.borderColor = viewModel.getNameBorder(forName: name)
    }
    
    @IBAction func onTapRegisterButton(_ sender: Any) {
        delegate?.shouldDismissKeyboard()
        nameChange(nameTextField: firstNameField)
        nameChange(nameTextField: secondNameField)
        emailAddressChange()
        passwordChange()
        guard let firstName = firstNameField.text,
              viewModel.isNameValid(firstName),
              let secondName = secondNameField.text,
              viewModel.isNameValid(secondName),
              let email = emailAddressTextBox.text,
              viewModel.isEmailValid(email),
              let password = passwordTextBox.text,
              viewModel.isPasswordStrong(password) else {
            delegate?.invalidFormSubmitted()
            return
        }
        print("Register Success")
    }
}

extension RegisterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameField.isFirstResponder {
            secondNameField.becomeFirstResponder()
        } else if secondNameField.isFirstResponder {
            emailAddressTextBox.becomeFirstResponder()
        } else if emailAddressTextBox.isFirstResponder {
            passwordTextBox.becomeFirstResponder()
        } else if passwordTextBox.isFirstResponder {
            onTapRegisterButton(self)
        }
        return true
    }
}
