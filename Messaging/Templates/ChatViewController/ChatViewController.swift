//
//  ChatViewController.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import UIKit
import FirebaseAuth
import MessageKit
import InputBarAccessoryView
import JGProgressHUD

class ChatViewController: MessagesViewController {
    static let kIdentifier = "ChatViewController"
    private let spinner = JGProgressHUD(style: .dark)
    
    let viewModel = ChatViewControllerViewModel()
    
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func setupConversation(name: String, email: String, conversationID: String?) {
        title = name
        viewModel.receiverName = name
        viewModel.receiverEmail = email
        viewModel.conversationID = conversationID
        listenForMessage()
    }
    
    fileprivate func initialSetup() {
        setupDataSourceDelegate()
    }
    
    fileprivate func listenForMessage() {
        guard let conversationID = viewModel.conversationID else { return }
        spinner.show(in: view)
        DatabaseManager.shared.getAllMessagesForConversation(with: conversationID) { [weak self] result in
            self?.spinner.dismiss()
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if self?.messages.isEmpty ?? true {
                        self?.messages = messages
                        self?.messagesCollectionView.reloadData()
                    } else {
                        self?.messages = messages
                        self?.messagesCollectionView.reloadDataAndKeepOffset()
                    }
                }
            case .failure(let error):
                debugPrint("Failed To Fetch messages \(error)")
            }
        }
    }
    
    fileprivate func setupDataSourceDelegate() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        guard let selfSender = viewModel.selfSender else {
            signOutUserAndForceCloseApp()
            return Sender(senderId: "", displayName: "", photoUrl: "")
        }
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
}


extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let messageId = viewModel.generateMessageID(),
              let selfSender = viewModel.selfSender else {
            signOutUserAndForceCloseApp()
            return
        }
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        if viewModel.isNewConversation {
            //Create Convo in DB
            self.messageInputBar.inputTextView.text = ""
            DatabaseManager.shared.createNewConversation(with: viewModel.receiverEmail, messageToSend : message, otherUserName: viewModel.receiverName) { [weak self] success in
                if success {
                    self?.messagesCollectionView.reloadData()
                    self?.viewModel.conversationID = messageId
                    self?.listenForMessage()
                    debugPrint("Message Sent")
                } else {
                    debugPrint("Failed To Send")
                }
            }
        } else {
            //Append Convo In DB
            guard let conversationID = viewModel.conversationID else {
                return
            }
            self.messageInputBar.inputTextView.text = ""
            DatabaseManager.shared.sendMessage(to: conversationID, senderEmail: viewModel.senderEmail ?? "", senderName: viewModel.senderName, message: message, receiverEmailId: viewModel.receiverEmail) { success in
                if success {
                    debugPrint("Message Sent")
                } else {
                    debugPrint("Failed To Send")
                }
            }
        }
    }
}
