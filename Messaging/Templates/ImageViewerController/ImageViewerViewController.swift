//
//  ImageViewerViewController.swift
//  Messaging
//
//  Created by Lourdes on 5/2/21.
//

import UIKit

class ImageViewerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl: URL?
    
    static let KIdentifier = "ImageViewerViewController"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    private func initialSetup() {
        imageView.sd_setImage(with: imageUrl) { [weak self] image, _, _, _ in
            if let image = image, let strongSelf = self {
                    let ratio = image.size.width / image.size.height
                if strongSelf.view.frame.width > strongSelf.view.frame.height {
                    let newHeight = strongSelf.view.frame.width / ratio
                    strongSelf.imageView.frame.size = CGSize(width: strongSelf.view.frame.width, height: newHeight)
                    }
                    else{
                        let newWidth = strongSelf.view.frame.height * ratio
                        strongSelf.imageView.frame.size = CGSize(width: strongSelf.view.frame.width, height: 1000)
                    }
            }
        }
        imageView.enablePinchToZoom()
    }
    
    @IBAction func onTapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
