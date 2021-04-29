//
//  ViewUtility.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit
import FirebaseAuth

func signOutUserAndForceCloseApp() {
    do {
        try FirebaseAuth.Auth.auth().signOut()
    } catch { }
    fatalError("User Cache Does Not Exist")
}

extension UIViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    static func initiateVC() -> Self? {
        let storyBoard = UIStoryboard(name: String(describing: self), bundle: Bundle.main)
        return storyBoard.instantiateViewController(withIdentifier: String(describing: self)) as? Self
    }
}
