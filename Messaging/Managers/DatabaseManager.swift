//
//  DatabaseManager.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}
// MARK:- Sending Messages
extension DatabaseManager {
    
    /// Creates A New Conversation With Target User
    public func createNewConversation(with otherUserEmail: String, messageToSend: Message, otherUserName: String, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.email) as? String else {
            signOutUserAndForceCloseApp()
            return
        }
        
        createNewConversationForUser(currentEmail, messageToSend, otherUserEmail, otherUserName) { [weak self] success in
            if success {
                let currentUserName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.name) as? String ?? ""
                self?.createNewConversationForUser(otherUserEmail, messageToSend, currentEmail, currentUserName) {
                    success in
                    completion(success)
                }
            } else {
                completion(success)
            }
        }
    }
    
    
    /// Fetches And Returns All Conversations For The User With Passed Im Email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/\(StringConstants.shared.database.conversations)").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary[StringConstants.shared.database.messageId] as? String,
                      let name = dictionary[StringConstants.shared.database.otherUserName] as? String,
                      let otherUserEmail = dictionary[StringConstants.shared.database.otherUserEmail] as? String,
                      let latestMessage = dictionary[StringConstants.shared.database.latestMessage] as? [String: Any],
                      let date = latestMessage[StringConstants.shared.database.date] as? String,
                      let isRead = latestMessage[StringConstants.shared.database.isRead] as? Bool,
                      let message = latestMessage[StringConstants.shared.database.message] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
    }
    
    /// Get All Messages For A Given Conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/\(StringConstants.shared.database.messagesArray)").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let content = dictionary[StringConstants.shared.database.content] as? String,
                      let dateString = dictionary[StringConstants.shared.database.date] as? String,
                      let isRead = dictionary[StringConstants.shared.database.isRead] as? Bool,
                      let messageId = dictionary[StringConstants.shared.database.messageId] as? String,
                      let otherUserName = dictionary[StringConstants.shared.database.otherUserName] as? String,
                      let otherUserEmail = dictionary[StringConstants.shared.database.senderEmail] as? String,
                      let messageType = dictionary[StringConstants.shared.database.messageType] as? String,
                      let date = dateString.getDateObject() else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return nil
                }
                
                let sender = Sender(senderId: otherUserEmail, displayName: otherUserName, photoUrl: getProfilePicPathFromEmail(email: otherUserEmail))
                
                var messageKind: MessageKind?
                if messageType == StringConstants.shared.messageKind.text {
                    messageKind = .text(content)
                } else if messageType == StringConstants.shared.messageKind.photo {
                    guard let imageUrl = URL(string: content) else { return nil }
                    messageKind = .photo(Media(url: imageUrl, image: nil, placeholderImage: UIImage(named: "image_placeholder") ?? UIImage(), size: CGSize(width: 300, height: 300)))
                } else if messageType == StringConstants.shared.messageKind.video {
                    guard let videoUrl = URL(string: content) else { return nil }
                    messageKind = .video(Media(url: videoUrl, image: nil, placeholderImage: UIImage(named: "video_placeholder") ?? UIImage(), size: CGSize(width: 300, height: 300)))
                }
                
                guard let messageKind = messageKind else {
                    return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text("Error Loading Message"))
                }
                
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: messageKind)
            }
            completion(.success(messages))
        }
    }
    
    fileprivate func updateLatestMessageForUser(emailOfUser: String, conversationID: String, message: Message, completion: @escaping (Bool) -> Void) {
        //Update Sender Latest Message
        self.database.child("\(emailOfUser)/\(StringConstants.shared.database.conversations)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var senderConversations = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            var position = 0
            var targetConversation: [String: Any]?
            
            for conversationIterating in senderConversations {
                if let currentConversationID = conversationIterating[StringConstants.shared.database.messageId] as? String,
                   currentConversationID == conversationID {
                    targetConversation = conversationIterating
                    break
                }
                position += 1
            }
            
            let updatedValue: [String: Any] = [
                StringConstants.shared.database.date: message.sentDate.getDateString(),
                StringConstants.shared.database.isRead: false,
                StringConstants.shared.database.message: self?.getMessageString(message) ?? "",
            ]
            
            targetConversation?[StringConstants.shared.database.latestMessage] = updatedValue
            guard let targetConversation = targetConversation else {
                completion(false)
                return
            }
            senderConversations[position] = targetConversation
            self?.database.child("\(emailOfUser)/\(StringConstants.shared.database.conversations)").setValue( senderConversations, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
    
    /// Send A Message To Target Conversation
    public func sendMessage(conversationID: String, senderEmail: String, senderName: String, message: Message, receiverEmailId: String, completion: @escaping (Bool) -> Void) {
        //Add New Message To Conversation
        database.child("\(conversationID)/\(StringConstants.shared.database.messagesArray)").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let collectionMessage: [String: Any] = [
                StringConstants.shared.database.messageId: message.messageId,
                StringConstants.shared.database.messageType: message.kind.rawValue,
                StringConstants.shared.database.content: self?.getMessageString(message) ?? "",
                StringConstants.shared.database.otherUserName: senderName,
                StringConstants.shared.database.senderEmail: senderEmail,
                StringConstants.shared.database.date: message.sentDate.getDateString(),
                StringConstants.shared.database.isRead: false
            ]
            
            currentMessages.append(collectionMessage)
            self?.database.child("\(conversationID)/\(StringConstants.shared.database.messagesArray)").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                //Update Sender Latest Message
                self?.updateLatestMessageForUser(emailOfUser: senderEmail, conversationID: conversationID, message: message, completion: completion)
                
                //Update Recepient Latest Message
                self?.updateLatestMessageForUser(emailOfUser: receiverEmailId, conversationID: conversationID, message: message, completion: completion)
            })
        }
    }
    
    
    // Creaet A messae Node
    private func createConversationNode(_ message: Message, _ otherUserEmail: String, _ otherUserName: String) -> [String: Any] {
        let messageDate = message.sentDate.getDateString()
        
        let messageString = getMessageString(message)
        
        let newConversationData: [String: Any] = [
            StringConstants.shared.database.messageId : message.messageId,
            StringConstants.shared.database.otherUserEmail : otherUserEmail,
            StringConstants.shared.database.otherUserName: otherUserName,
            StringConstants.shared.database.latestMessage : [
                StringConstants.shared.database.date : messageDate,
                StringConstants.shared.database.message : messageString,
                StringConstants.shared.database.isRead : false,
            ]
        ]
        return newConversationData
    }
    
    // MARK:- Message Sending Support methodds
    
    private func getMessageString(_ message: Message) -> String {
        var messageString = ""
        switch message.kind {
        
        case .text(let messageText):
            messageString = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let urlString = mediaItem.url?.absoluteString {
                messageString = urlString
            }
        case .video(let mediaItem):
            if let urlString = mediaItem.url?.absoluteString {
                messageString = urlString
            }
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
        return messageString
    }
    
    fileprivate func createNewConversationForUser(_ currentUserEmail: String, _ messageToSend: Message, _ otherUserEmail: String, _ otherUserName: String, _ completion: @escaping (Bool) -> Void) {
        let reference = database.child(currentUserEmail)
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                debugPrint("User Not Found")
                return
            }
            if var conversations = userNode[StringConstants.shared.database.conversations] as? [[String: Any]] {
                //Conversation Array Exists
                //Appending Messages
                guard let messageNode = self?.createConversationNode(messageToSend, otherUserEmail, otherUserName) else {
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
                    self?.createConversationNode(messageToSend, otherUserEmail, otherUserName)
                ]
                reference.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        debugPrint("Error In Writing Message To Database")
                        completion(false)
                        return
                    }
                    let currentUserName = UserDefaults.standard.value(forKey: StringConstants.shared.userDefaults.name) as? String ?? ""
                    self?.finishCreatingConversation(message: messageToSend, currentUserEmail: otherUserEmail, otherUserName: currentUserName, completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(message: Message, currentUserEmail: String, otherUserName: String, completion: @escaping (Bool) -> Void) {
        let messageDict: [String: Any] = [
            StringConstants.shared.database.messageId: message.messageId,
            StringConstants.shared.database.messageType: message.kind.rawValue,
            StringConstants.shared.database.content: getMessageString(message),
            StringConstants.shared.database.otherUserName: otherUserName,
            StringConstants.shared.database.senderEmail: currentUserEmail,
            StringConstants.shared.database.date: message.sentDate.getDateString(),
            StringConstants.shared.database.isRead: false
        ]
        
        let value: [String: Any] = [
            StringConstants.shared.database.messagesArray: [
                messageDict
            ]
        ]
        
        database.child(message.messageId).setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
}

// MARK: - Accounts Management
extension DatabaseManager {
    /// Check If User With Email Exists
    public func doesUserExist(with email: String, completionWithUsername: @escaping ((String?) -> Void)) {
        database.child(StringConstants.shared.database.users).observeSingleEvent(of: .value) { (snapShot) in
            guard let value = snapShot.value as? [[String: String]] else {
                completionWithUsername(nil)
                return
            }
            let userToSearch = value.filter({$0[StringConstants.shared.database.safeEmail] == email})
            let userName = userToSearch.first?[StringConstants.shared.database.name]
            completionWithUsername(userName)
        }
    }
    
    /// Inserts New User To Database
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
    
    /// Get List With All Users
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

// MARK: - Get Any Data
extension DatabaseManager {
    /// Get Data For Path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

extension DatabaseManager {
    /// Converrts Email To Safe Email
    static func getSafeEmail(from emailAddress: String) -> String {
        return emailAddress.replacingOccurrences(of: ".", with: "^")
    }
}

// MARK:- Database Errors
public enum DatabaseError: Error {
    case failedToFetch
}
