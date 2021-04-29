//
//  DateUtility.swift
//  Messaging
//
//  Created by Lourdes on 4/30/21.
//

import UIKit

let dateFormatter = DateFormatter()

extension Date {
    func getDateString() -> String {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
