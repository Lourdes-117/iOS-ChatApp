//
//  ImageZoomView.swift
//  Messaging
//
//  Created by Lourdes on 5/2/21.
//

import UIKit

import UIKit

class ImageZoomView: UIScrollView, UIScrollViewDelegate {
    
    var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer!
    
    convenience init(frame: CGRect, image: UIImage?) {
        self.init(frame: frame)
        
        var imageToUse: UIImage
        
        if let image = image {
            imageToUse = image
        } else if let url = Bundle.main.url(forResource: "image", withExtension: "jpeg"),
            let data = try? Data(contentsOf: url),
            let fileImage = UIImage(data: data) {
            imageToUse = fileImage
        } else {
            fatalError("No image was passed in and failed to find an image at the path.")
        }
        
        // Creates the image view and adds it as a subview to the scroll view
        imageView = UIImageView(image: imageToUse)
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        setupScrollView(image: imageToUse)
        setupGestureRecognizer()
    }
    
    // Sets the scroll view delegate and zoom scale limits.
    // Change the `maximumZoomScale` to allow zooming more than 2x.
    func setupScrollView(image: UIImage) {
        delegate = self
        
        minimumZoomScale = 1.0
        maximumZoomScale = 2.0
    }
    
    // Sets up the gesture recognizer that receives double taps to auto-zoom
    func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(gestureRecognizer)
    }

    // Handles a double tap by either resetting the zoom or zooming to where was tapped
    @IBAction func handleDoubleTap() {
        if zoomScale == 1 {
            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }

    // Calculates the zoom rectangle for the scale
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    // Tell the scroll view delegate which view to use for zooming and scrolling
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
