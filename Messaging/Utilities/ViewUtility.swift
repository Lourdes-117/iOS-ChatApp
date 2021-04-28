//
//  ViewUtility.swift
//  Messaging
//
//  Created by Lourdes on 4/23/21.
//

import UIKit

extension UIView {
    
    func setRoundedCorners() {
        self.layer.cornerRadius = self.frame.size.width/2
    }
    
    func commonInit(_ nibName: String) {
        guard let view = loadViewFromNib(nibName) else {
            return
        }
        view.addAsSubViewWithEqualConstraintTo(self)
    }
    
    func loadViewFromNib(_ nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)

        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func addAsSubViewWithEqualConstraintTo(_ containerView: UIView) {
        self.frame = containerView.bounds
        containerView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0),
            self.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0.0),
            self.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0.0),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0)
            ])
    }
}
