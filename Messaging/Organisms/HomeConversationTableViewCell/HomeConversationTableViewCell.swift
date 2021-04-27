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
    
    var cellTitle: String? {
        set {
            title.text = newValue
        }
        
        get {
            title.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    private func initialSetup() {
        self.accessoryType = .disclosureIndicator
    }
}
