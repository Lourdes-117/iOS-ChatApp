//
//  ImageViewerViewController.swift
//  Messaging
//
//  Created by Lourdes on 5/2/21.
//

import UIKit

class ImageViewerViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    var imageUrl: URL?
    
    static let KIdentifier = "ImageViewerViewController"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    private func initialSetup() {
        UIImageView().sd_setImage(with: imageUrl) { [weak self] image, _, _, _ in
            let imageView = ImageZoomView(frame: self?.backgroundView.frame ?? CGRect(), image: image)
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 5
            self?.backgroundView.addSubview(imageView)
        }
    }
    
    @IBAction func onTapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
