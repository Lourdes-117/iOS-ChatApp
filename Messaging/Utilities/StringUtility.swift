//
//  StringExtensions.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import Foundation

extension String {
    func matchesRegex(_ regexString: String) -> Bool {
        let regex = NSPredicate(format:"SELF MATCHES %@", regexString)
        return regex.evaluate(with: self)
    }
    
    var hasUpperCase: Bool {
        for currentCharacter in self.unicodeScalars {
            if CharacterSet.uppercaseLetters.contains(currentCharacter) { return true }
        }
        return false
    }
    
    var hasLowerCase: Bool {
        for currentCharacter in self.unicodeScalars {
            if CharacterSet.lowercaseLetters.contains(currentCharacter) { return true }
        }
        return false
    }
}
