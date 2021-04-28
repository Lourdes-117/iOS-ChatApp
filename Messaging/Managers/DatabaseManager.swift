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
                print("Failed To Write To Database")
                completion(false)
                return
            }
            completion(true)
        }
        
        self.database.child(StringConstants.shared.database.users).observeSingleEvent(of: .value) { [weak self] snapShot in
            if var userCollection = snapShot.value as? [[String: String]] {
                let newElement: [String: String] = [
                        StringConstants.shared.database.name: "\(user.firstName) \(user.lastName)",
                        StringConstants.shared.database.safeEmail: user.safeEmail
                    ]
                userCollection.append(newElement)
                self?.database.child(StringConstants.shared.database.users).setValue(userCollection)
            } else {
                let newCollection: [[String: String]] = [
                    [
                        StringConstants.shared.database.name: "\(user.firstName) \(user.lastName)",
                        StringConstants.shared.database.safeEmail: user.safeEmail
                    ]
                ]
                self?.database.child(StringConstants.shared.database.users).setValue(newCollection)
            }
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child(StringConstants.shared.database.users).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
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

public enum DatabaseError: Error {
    case failedToFetch
}
