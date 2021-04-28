//
//  ImageViewUtility.swift
//  Messaging
//
//  Created by Lourdes on 4/29/21.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func loadImage(from url: String?, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let urlString = url, let urlObject = URL(string: urlString) else { return }
        loadImage(from: urlObject, contentMode: mode)
    }
}
