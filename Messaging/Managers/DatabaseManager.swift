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

// MARK:- Sending Messages
extension DatabaseManager {
    /// Creates A New Conversation With Target User
    public func createNewConversation(with otherUserEmail: String, messageToSend: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email) as? String else {
            signOutUserAndForceCloseApp()
            return
        }
        let reference = database.child(currentEmail)
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                debugPrint("User Not Found")
                return
            }
            if var conversations = userNode[StringConstants.shared.database.conversations] as? [[String: Any]] {
                //Conversation Array Exists
                //Appending Messages
                guard let messageNode = self?.createConversationNode(messageToSend, otherUserEmail) else {
                    completion(false)
                    return
                }
                conversations.append(messageNode)
                userNode[StringConstants.shared.database.conversations] = conversations
                reference.setValue(userNode) { error, _ in
                    guard error == nil else {
                        debugPrint("Error In Writing Message To Database")
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            } else {
                //Conversation Array Does Not Exist
                //Creare Array
                userNode[StringConstants.shared.database.conversations] = [
                    self?.createConversationNode(messageToSend, otherUserEmail)
                ]
                reference.setValue(userNode) { error, _ in
                    guard error == nil else {
                        debugPrint("Error In Writing Message To Database")
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    
    /// Fetches And Returns All Conversations For The User With Passed Im Email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Get All Messages For A Given Conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send A Message To Target Conversation
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    // Creaet A messae Node
    private func createConversationNode(_ message: Message, _ otherUserEmail: String) -> [String: Any] {
        let messageDate = message.sentDate.getDateString()
        
        var messageToSend = ""
        switch message.kind {
        
        case .text(let messageText):
            messageToSend = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let newConversationData: [String: Any] = [
            StringConstants.shared.database.messageId : message.messageId,
            StringConstants.shared.database.otherUserEmail : otherUserEmail,
            StringConstants.shared.database.latestMessage : [
                StringConstants.shared.database.date : messageDate,
                StringConstants.shared.database.message : messageToSend,
                StringConstants.shared.database.isRead : false,
            ]
        ]
        return newConversationData
    }
}

// MARK: - Account Management
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

// MARK:- Database Errors
public enum DatabaseError: Error {
    case failedToFetch
}
