//
//  HomeConversationTableViewCell.swift
//  Messaging
//
//  Created by Lourdes on 4/26/21.
//

import UIKit

class HomeConversationTableViewCell: UITableViewCell {
    static let kIdentifier = "HomeConversationTableViewCell"
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    private func initialSetup() {
        self.accessoryType = .disclosureIndicator
    }

    func setNameOfUser(_ name: String) {
        title.text = name
    }

}
