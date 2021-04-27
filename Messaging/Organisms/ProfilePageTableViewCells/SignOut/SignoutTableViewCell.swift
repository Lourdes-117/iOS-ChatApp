//
//  SignoutTableViewCell.swift
//  Messaging
//
//  Created by Lourdes on 4/28/21.
//

import UIKit

class SignoutTableViewCell: UITableViewCell {
    static let kIdentifier = "SignoutTableViewCell"
    
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
        
    }
}
