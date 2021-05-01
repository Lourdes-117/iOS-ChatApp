//
//  HomeConversationTableViewCell.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import UIKit
import SDWebImage

class HomeConversationTableViewCell: UITableViewCell {
    static let kIdentifier = "HomeConversationTableViewCell"
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setupCell(userName: String?, latestMessage: String?, email: String) {
        if let userName = userName {
            userNameLabel.text = userName
        }
        if let message = latestMessage {
            messageLabel.text = message
        } else {
            messageLabel.isHidden = true
        }
        
        let path = getProfilePicPathFromEmail(email: email)
        StorageManager.shared.downloadUrl(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profilePictureView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                debugPrint("failed to get url \(error)")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    private func initialSetup() {
        profilePictureView.setRoundedCorners()
    }
}
