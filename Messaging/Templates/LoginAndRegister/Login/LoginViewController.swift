//
//  LoginViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/22/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    static let kIdentifier = "LoginViewController"
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginView: LoginView!
    @IBOutlet weak var registerView: RegisterView!
    @IBOutlet weak var scrollView: UIScrollView!
    var registerOrLoginSwitchButton: UIBarButtonItem?
    @IBOutlet weak var profilePicView: UIImageView!
    
    let viewModel = LoginControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func initialSetup() {
        registerOrLoginSwitchButton = UIBarButtonItem(title: viewModel.pageTitle, style: .done, target: self, action: #selector(onTapLoginRegisterSwitchButton))
        loginView.isHidden = false
        registerView.isHidden = true
        navigationItem.rightBarButtonItem = registerOrLoginSwitchButton
        imageViewWidthConstraint.constant = view.frame.width/3
        title = viewModel.pageTitle
        registerOrLoginSwitchButton?.title = viewModel.loginRegisterSwitchButtonTitle
        profilePicView.layer.masksToBounds = true
    }
    
    fileprivate func setupDelegates() {
        loginView.delegate = self
        registerView.delegate = self
    }
    
    @IBAction func didTapProfilePicture(_ sender: Any) {
        if viewModel.isOnLoginPage { return }
        presentPhotoActionSheet()
    }
    
    @objc func onTapLoginRegisterSwitchButton() {
        self.dismissKeyboard()
        viewModel.isOnLoginPage.toggle()
        title = viewModel.pageTitle
        registerOrLoginSwitchButton?.title = viewModel.loginRegisterSwitchButtonTitle
        loginView.isHidden = viewModel.shouldHideLoginPage
        registerView.isHidden = viewModel.shouldHideRegisterPage
        loginView.resetView()
        registerView.resetView()
    }
    
    func presentInvalidFormAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title ?? viewModel.formInvalidAlertTitle, message: message ?? viewModel.formInvalidAlertMessage , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: viewModel.alertDismissMessage, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

extension LoginViewController: LoginRegisterViewDelegate {
    func successfulLoginOrRegister(email: String, password: String, firstName: String?, lastName: String?) {
        if viewModel.isOnLoginPage {
            //Login
            spinner.show(in: view)
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authDataResult, error) in
                self?.didSignInSuccessfully(authDataResult: authDataResult, error: error)
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
            }
        } else {
            //Register
            spinner.show(in: view)
            guard let first = firstName,
                  let last = lastName else { return }
            let user = ChatAppUserModel(firstName: first,
                                        lastName: last,
                                        emailAddress: email)
            DatabaseManager.shared.doesUserExist(with: user.safeEmail) { [weak self] (doesExist) in
                if doesExist {
                    self?.presentInvalidFormAlert(title: self?.viewModel.userExistsTitle, message: self?.viewModel.userExistsMessage)
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                    }
                    return
                }
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
                    guard let result = authResult, error == nil else {
                        self?.presentInvalidFormAlert(title: self?.viewModel.error, message: self?.viewModel.pleaseTryAgain)
                        DispatchQueue.main.async {
                            self?.spinner.dismiss()
                        }
                        return
                    }
                    debugPrint(result)
                }
                DatabaseManager.shared.insertUser(with: user) { (success) in
                    if success {
                        guard let imageData = self?.profilePicView.image?.pngData() else { return }
                        let fileName = user.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: imageData,
                                                                   fileName: fileName) { (result) in
                            switch result {
                            case .success(let downloaUrl):
                                UserDefaults.standard.setValue(downloaUrl, forKey: StringConstants.shared.userDefaults.profilePicurl)
                                //Sign in after all uploads are successful
                                FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                                    self?.didSignInSuccessfully(authDataResult: authDataResult, error: error)
                                    DispatchQueue.main.async {
                                        self?.spinner.dismiss()
                                    }
                                }
                            case .failure(let error):
                                debugPrint(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shouldDismissKeyboard() {
        self.dismissKeyboard()
    }
    
    func invalidFormSubmitted() {
        self.presentInvalidFormAlert()
    }
    
    func didSignInSuccessfully(authDataResult: AuthDataResult?, error: Error?) {
        if authDataResult == nil, let error = error {
            debugPrint(error)
            self.presentInvalidFormAlert(title: viewModel.error,
                                         message: viewModel.pleaseTryAgain)
            return
        }
        debugPrint("Signin Successful")
        guard let window = UIApplication.shared.windows.first, FirebaseAuth.Auth.auth().currentUser != nil else {
            self.presentInvalidFormAlert(title: viewModel.error,
                                         message: viewModel.pleaseTryAgain)
            return
        }
        UIView.animate(withDuration: kAnimationDuration*5) { [weak self] in
            self?.view.alpha = 0
        } completion: { (_) in
            let mainStoryBoard = UIStoryboard(name: HomeViewController.kIdentifier, bundle: nil)
                let viewController = mainStoryBoard.instantiateViewController(withIdentifier: HomeViewController.kIdentifier)
            viewController.view.alpha = 0
            let navController = UINavigationController(rootViewController: viewController)
                window.rootViewController = navController
            UIView.animate(withDuration: kAnimationDuration*5) {
                viewController.view.alpha = 1
            }
        }
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: viewModel.profilePicSelectionTitle, message: viewModel.profilePicSelectionMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: viewModel.cancel, style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: viewModel.takePhoto, style: .default, handler: {[weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.choosePhoto, style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
