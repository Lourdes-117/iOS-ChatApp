//
//  DatabaseManager.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// Mark: - Account Management
extension DatabaseManager {
    ///Check If User With Email Exists
    public func doesUserExist(with email: String, completion: @escaping ((Bool) -> Void)) {
        database.child(email).observeSingleEvent(of: .value) { (snapShot) in
            guard snapShot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///Inserts New User To Database
    public func insertUser(with user: ChatAppUserModel, completion: @escaping (Bool)-> Void ) {
        database.child(DatabaseManager.getSafeEmail(from: user.emailAddress)).setValue([
                                                    StringConstants.shared.database.firstName: user.firstName,
                                                    StringConstants.shared.database.lastName: user.lastName]) { (error, databaseReference) in
            guard error == nil else {
                print("Failed To Write To Databae")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

extension DatabaseManager {
    static func getSafeEmail(from emailAddress: String) -> String {
        var email = emailAddress.replacingOccurrences(of: "@", with: "!")
        email = emailAddress.replacingOccurrences(of: ".", with: "^")
        return email
    }
}
