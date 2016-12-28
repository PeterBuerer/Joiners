//
//  ViewController.swift
//  Joiners
//
//  Created by Peter Buerer on 11/1/16.
//  Copyright © 2016 Peter Buerer. All rights reserved.
//

import UIKit

class CanvasController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    init() {
        super.init(nibName: nil, bundle: nil)
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImage))
        navigationItem.rightBarButtonItem = addItem
        // make sure that the view doesn't extend up under navigation bar
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    // MARK: - Actions
    
    var startPoint = CGPoint.zero
    func moveImage(gesture: UIPanGestureRecognizer) {
       
        guard let imageView = gesture.view as? DraggableImageView else {
            print("View not draggable image")
            return
        }
        
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            startPoint = translation
            print("Start: \(startPoint)")
        case .changed:
            guard let imageSuperView = imageView.superview else {
                return
            }
            // only update the horizontal position of the imageView if it isn't going to go halfway off the side
            let xDelta = imageView.frame.origin.x + (translation.x - startPoint.x)
            let halfWidth = imageView.frame.size.width / 2
            if xDelta > -halfWidth && xDelta < imageSuperView.frame.width - halfWidth {
                imageView.horizontalConstraint.constant += translation.x - startPoint.x
                startPoint.x = translation.x
            }
            // only update the vertical position of the imageView if it isn't going to go halfway off the top or bottom
            let yDelta = imageView.frame.origin.y + (translation.y - startPoint.y)
            let halfHeight = imageView.frame.size.height / 2
            if yDelta > -halfHeight && yDelta < imageSuperView.frame.height - halfHeight {
                imageView.verticalConstraint.constant += translation.y - startPoint.y
                startPoint.y = translation.y
            }
            print("DeltaX: \(xDelta)")
            print("DeltaY: \(yDelta)")
            print("Super height: \(imageSuperView.frame.height)")
            print("Super width: \(imageSuperView.frame.width)")
            break
        case .ended:
            break
        default:
            break
        }
        
        print("gesture: \(translation)")
        print("Velocity: \(gesture.velocity(in: view))")
    }
    
    func pickImage() {
        guard let image = UIImage(named:"vapeNaysh.jpeg") else {
            return
        }
        
        add(image: image)
        // TODO: ask permission before presenting
        // if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //     let imagePickerController = UIImagePickerController()
        //     imagePickerController.sourceType = .camera
        //     imagePickerController.delegate = self
        //     present(imagePickerController, animated: true, completion: nil)
        // }
        // else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        //      let imagePickerController = UIImagePickerController()
        //     imagePickerController.sourceType = .photoLibrary
        //     imagePickerController.delegate = self
        //     present(imagePickerController, animated: true, completion: nil)
        // }
    }
   
    func add(image: UIImage) {
        let imageView = DraggableImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        imageView.isUserInteractionEnabled = true
        imageView.image = image
        view.addSubview(imageView)
        
        imageView.horizontalConstraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        imageView.verticalConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        imageView.horizontalConstraint.isActive = true
        imageView.verticalConstraint.isActive = true
        
        
        let views: [String : Any] = [ "image": imageView, "topLayoutGuide": topLayoutGuide ]
        let imageSize = imageView.intrinsicContentSize
        let metrics = [ "height": imageSize.height, "width": imageSize.width ]
            
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-(>=0)-[image]-(>=0)-|", options: [], metrics: nil, views: views))
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[image]-(>=0)-|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[image(==height)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[image(==width)]", options: [], metrics: metrics, views: views))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.moveImage(gesture:)))
        imageView.addGestureRecognizer(panGesture)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        add(image: image)
        dismiss(animated: true, completion: nil)
    }
}

