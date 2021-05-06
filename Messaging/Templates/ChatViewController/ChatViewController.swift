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
import SDWebImage
import AVFoundation
import AVKit

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
        setupInputBar()
    }
    
    // MARK:- Adding Media
    func setupInputBar() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(viewModel.inputBarButtonIcon, for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: viewModel.attachMediaTitle, message: viewModel.attachMediaMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: viewModel.photo, style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.video, style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.audio, style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.cancel, style: .cancel, handler: { [weak self] _ in
            
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: viewModel.attachPhotoTitle, message: viewModel.attachPhotoMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: viewModel.camera, style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = false
            self?.present(picker, animated: false, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.photoLibrary, style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            self?.present(picker, animated: false, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.cancel, style: .cancel, handler: { [weak self] _ in
            
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: viewModel.attachVideoTitle, message: viewModel.attachVideoMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: viewModel.camera, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = [strongSelf.viewModel.mediaTypeForVideo]
            picker.videoQuality = strongSelf.viewModel.videoQualityType
            self?.present(picker, animated: false, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.photoLibrary, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = [strongSelf.viewModel.mediaTypeForVideo]
            picker.videoQuality = strongSelf.viewModel.videoQualityType
            self?.present(picker, animated: false, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: viewModel.cancel, style: .cancel, handler: { [weak self] _ in
            
        }))
        present(actionSheet, animated: true, completion: nil)
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
        messagesCollectionView.messageCellDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ImageViewerViewController {
            viewController.imageUrl = viewModel.selectedImageUrl
        }
    }
}

// MARK:- Message Datasource
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}


// MARK:- Message Delegate
extension ChatViewController: MessagesLayoutDelegate {
    
}

extension ChatViewController: MessagesDisplayDelegate {
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubbleTail(.bottomRight, .curved) : .bubbleTail(.bottomLeft, .pointedEdge)
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        dismissKeyboard()
        guard let section = messagesCollectionView.indexPath(for: cell)?.section else { return }
        let message = messages[section]
        switch message.kind {
        case .photo(let media):
            viewModel.selectedImageUrl = media.url
            performSegue(withIdentifier: viewModel.imageViewerSegueIdentifier, sender: nil)
        case .video(let media):
            viewModel.selectedVideoUrl = media.url
            let videoController = AVPlayerViewController()
            videoController.player = AVPlayer(url: viewModel.selectedVideoUrl!)
            videoController.player?.play()
            present(videoController, animated: true)
        default:
            break
        }
    }
}

// MARK:- Input Bar Delegate
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
            DatabaseManager.shared.sendMessage(conversationID: conversationID, senderEmail: viewModel.senderEmail ?? "", senderName: viewModel.senderName, message: message, receiverEmailId: viewModel.receiverEmail) { success in
                if success {
                    debugPrint("Message Sent")
                } else {
                    debugPrint("Failed To Send")
                }
            }
        }
    }
}


// MARK:- Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        // Upload Image
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let imageData = image.jpeg(.low) {
            guard let messageID = viewModel.generateMessageID(),
                  let conversationID = viewModel.conversationID,
                  let selfSender = viewModel.selfSender,
                  let senderEmail = viewModel.senderEmail,
                  let lowResImageData = image.jpeg(.lowest),
                  let lowResImage = UIImage(data: lowResImageData) else { return }
            
            //Upload Image
            let fileName = "\(messageID)\(StringConstants.shared.storage.messageImageExtension)"
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let urlString):
                    let url = URL(string: urlString)
                    let media = Media(url: url, image: image, placeholderImage: lowResImage, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .photo(media))
                    //Sending Message
                    DatabaseManager.shared.sendMessage(conversationID: conversationID, senderEmail: senderEmail, senderName: strongSelf.viewModel.senderName, message: message, receiverEmailId: strongSelf.viewModel.receiverEmail) { success in
                        if success {
                            debugPrint("Image Message Sent")
                        } else {
                            debugPrint("Image Message Sending Failure")
                        }
                    }
                case .failure(let error):
                    debugPrint("Message Photo upload Error \(error)")
                }
            }
        } else if let videoUrl = info[.mediaURL] as? URL,
                  let messageID = viewModel.generateMessageID(),
                  let selfSender = viewModel.selfSender,
                  let senderEmail = viewModel.senderEmail,
                  let conversationID = viewModel.conversationID  {
            let fileName = "\(messageID)\(StringConstants.shared.storage.messageVideoExtension)"
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self ] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let urlString):
                    debugPrint("Uploaded Video")
                    let url = URL(string: urlString)
                    let media = Media(url: url, image: nil, placeholderImage: UIImage(), size: .zero)
                    let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .video(media))
                    //Sending Message
                    DatabaseManager.shared.sendMessage(conversationID: conversationID, senderEmail: senderEmail, senderName: strongSelf.viewModel.senderName, message: message, receiverEmailId: strongSelf.viewModel.receiverEmail) { success in
                        if success {
                            debugPrint("Image Message Sent")
                        } else {
                            debugPrint("Image Message Sending Failure")
                        }
                    }
                case .failure(let error):
                    debugPrint("Video Upload Failed \(error)")
                }
            }
        }
    }
}


extension ChatViewController: UINavigationControllerDelegate {
    
}
