//
//  ViewController.swift
//  Joiners
//
//  Created by Peter Buerer on 11/1/16.
//  Copyright © 2016 Peter Buerer. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreData

typealias CanvasControllerCompletion = () -> Void

class CanvasController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    private var selectedImage: JoinerImageView?
    private var imageViews = [JoinerImageView]()
    private var joiner: Joiner
    private var container: NSPersistentContainer
    private var completion: CanvasControllerCompletion
    
    // TODO: Create an abstraction layer between the database and the view controller so that this isn't tied to Core Data
    init(_ joiner: Joiner, container: NSPersistentContainer, completion: @escaping CanvasControllerCompletion) {
        self.joiner = joiner
        self.container = container
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        let addItem = UIBarButtonItem(title: "Library", style: .plain, target: self, action: #selector(pickImage))
        let takePhotoItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
        let resetItem = UIBarButtonItem(title: "Reset Image", style: .plain, target: self, action: #selector(resetImage))
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveJoiner))
        
        let rightItems = [saveItem, takePhotoItem, addItem]
        navigationItem.rightBarButtonItems = rightItems
        navigationItem.leftBarButtonItem = resetItem
        
        // make sure that the view doesn't extend up under navigation bar
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        print("Setup joiner images for: \(joiner)")
        populateCanvas(seedJoiner: joiner)
    }
   
    
    // MARK: - Actions
    
    var startPoint = CGPoint.zero
    func moveImage(gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view as? JoinerImageView, imageView.selected else {
            print("View not Joiner image or not selected to move")
            return
        }
        
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            startPoint = translation
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
            break
        case .ended:
            break
        default:
            break
        }
    }
    
    func scaleImage(gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view as? JoinerImageView, imageView.selected else {
            return
        }
        
        imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    func rotateImage(gesture: UIRotationGestureRecognizer) {
        guard let imageView = gesture.view as? JoinerImageView, imageView.selected else {
            return
        }
        
        imageView.transform = imageView.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0;
    }
    
    func selectImage(gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? JoinerImageView else {
            print("View not Joiner image")
            return
        }
        select(imageView: imageView);
    }
    
    func select(imageView: JoinerImageView) {
        selectedImage?.selected = false
        imageView.selected = true
        selectedImage = imageView
    }
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.showCamera()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Could not Open Camera", message: "Please make sure that this app has permission to access the camera in Settings.", preferredStyle: .alert)
                            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                            let settingsButton = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                                guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
                                    return
                                }
                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                            })
                            
                            alertController.addAction(cancelButton)
                            alertController.addAction(settingsButton)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
       }
        else {
            let alertController = UIAlertController(title: "Could not Open Camera", message: "The camera could not be accessed at this time.", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelButton)
        }
    }
    
    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization({ [unowned self] (status) in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.showPhotoLibrary()
                    }
                default:
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Could not Access the Photo Library", message: "Please make sure that this app has permission in Settings to access the photo library.", preferredStyle: .alert)
                        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        let settingsButton = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                            guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        })
                        
                        alertController.addAction(cancelButton)
                        alertController.addAction(settingsButton)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            })
        }
        else {
            let alertController = UIAlertController(title: "Could not Access the Photo Library", message: "The photo library could not be accessed at this time.", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelButton)
        }
    }
    
    // TODO: Figure out why the camera and photo library take forever to present

    func showCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.showsCameraControls = true;
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func showPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func saveJoiner() {
        print("Save joiner")
        let saveBlock = { [unowned self] in
            for imageView in self.imageViews {
                guard let joinerImage = imageView.joinerImage else {
                    print("No JoinerImage found when trying to save ImageView")
                    continue
                }
                
                joinerImage.joiner = self.joiner
                joinerImage.transform = NSStringFromCGAffineTransform(imageView.transform)
                joinerImage.xPosition = Double(imageView.horizontalConstraint.constant)
                joinerImage.yPosition = Double(imageView.verticalConstraint.constant)
            }
            
            let successfulSave = self.container.saveViewContext()
            if !successfulSave {
                print("Couldn't save Joiner")
                // Give option to quit even though the save failed
                let alertController = UIAlertController(title: "Error", message: "Could not save joiner", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Leave without saving", style: .destructive, handler: { [unowned self] (action) in
                    self.completion()
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                self.completion()
            }
        }
        
        // save new joiner from current images
        
        // keep the current name in case they type stuff and hit cancel
        let preSaveName = joiner.name
        // get name and save
        let alertController = UIAlertController(title: "Save Joiner", message: "What would you like to call this Joiner?", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { [unowned self] (textfield) in
            textfield.delegate = self
            textfield.text = self.joiner.name
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] (action) in
            self.joiner.name = preSaveName
        }))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            // save to db and show menu
            saveBlock();
        }))
        
        present(alertController, animated: true)
    }
    
    
    // MARK:- Save Joiner UITextFieldDelegate
   
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        joiner.name = textField.text
    }
    
    
    // remove all transforms on the selected image and place it in the center of the screen
    func resetImage() {
        selectedImage?.horizontalConstraint.constant = 0
        selectedImage?.verticalConstraint.constant = 0
        selectedImage?.transform = .identity
    }
    
    // TODO: Refactor so you only pass one image thing in. It is not clear when you read the types UIImage and JoinerImage that you can't just have a JoinerImage
    func addImageViewFor(image: UIImage, joinerImage: JoinerImage, scaleToFit: Bool = true) -> JoinerImageView? {
        let imageView = JoinerImageView(joinerImage: joinerImage)
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
       
        let imageSize = imageView.intrinsicContentSize
        var scaleRatio = CGFloat(1)
        // scale images to fit screen
        if scaleToFit {
            // arbitrary borderOffset; just need some space between the edge of image and the edge of the view
            let borderOffset = CGFloat(32.0)
            // TODO: fix problem where the canvas' width/height information is pulled when portrait picker modal is up but canvas is in landscape
                // Also, when populating an existing Joiner you aren't guaranteed that the orientation and view size will be the same   
                // And there seems to be a difference if you save in landscape vs portrait (without moving the images)...Orientation stuff is probably going to be a big deal and there are likely lots of other scenarios to cover
            let maxStartingWidth = view.frame.width - borderOffset
            let maxStartingHeight = view.frame.height - borderOffset
            
            print("Maxstartwidth: \(maxStartingWidth) \nMaxstartheight: \(maxStartingHeight)")
            print("Imagewidth: \(imageSize.width) \nImageHeight: \(imageSize.height)")
            
            let widthRatio = maxStartingWidth / imageSize.width
            let heightRatio = maxStartingHeight / imageSize.height
            scaleRatio = min(widthRatio, heightRatio)
        }
       
        let startingWidth = imageSize.width * scaleRatio
        let startingHeight = imageSize.height * scaleRatio
        
        let metrics = [ "width": startingWidth, "height": startingHeight]
        let views: [String : Any] = ["image": imageView, "topLayoutGuide": topLayoutGuide]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[image(==height)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[image(==width)]", options: [], metrics: metrics, views: views))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveImage(gesture:)))
        pan.maximumNumberOfTouches = 1
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(gesture:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(gesture:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage(gesture:)))
        
        imageView.addGestureRecognizer(pan)
        imageView.addGestureRecognizer(pinch)
        imageView.addGestureRecognizer(rotate)
        imageView.addGestureRecognizer(tap)
        
        imageViews.append(imageView)
        return imageView
    }
   
    // only call when adding a new image to the joiner
    func add(image: UIImage) {
        guard let newJoinerImage = NSEntityDescription.insertNewObject(forEntityName: "JoinerImage", into: container.viewContext) as? JoinerImage else {
            print("Could not create JoinerImage Managed Object")
            return
        }
        
        // TODO: add and manage a z-index so images at least show up in the same order they are added 
        
        // TODO: might make sense to put this in the save function where the rest of the data is offloaded to the Managed Object....?
            // It is possible though that doing that with a lot of images would be very slow...
        newJoinerImage.image = UIImageJPEGRepresentation(image, 1.0) as NSData? // Note: JPEG saves rotation data. PNG sets exif and you have to do rotation yourself
        
        // make new JoinerImageView
        guard let imageView = addImageViewFor(image: image, joinerImage: newJoinerImage) else {
            // TODO: remove the JoinerImage you just made for this JoinerImageView....and tell the user...
            print("Could not add Imageview for JoinerImage")
            return
        }
        
        select(imageView: imageView)
    }
    
    func populateCanvas(seedJoiner: Joiner) {
        guard let joinerImages = seedJoiner.images else {
            print("No JoinerImages in seed Joiner")
            return
        }
       
        // TODO: warn user if anything in this fails?
        for joinerImage in joinerImages {
            guard let joinerImage = joinerImage as? JoinerImage else {
                print("Could not cast Managed Object to JoinerImage")
                continue
            }
            
            guard let imageData = joinerImage.image as? Data else {
                print("No image data from JoinerImage")
                continue
            }
            
            guard let image = UIImage(data: imageData) else {
                print("Could not make UIImage from Joiner image data")
                continue
            }
            
            guard let imageView = addImageViewFor(image: image, joinerImage: joinerImage) else {
                print("Could not add ImageView")
                return
            }
            
            guard let transform = joinerImage.transform else {
                print("Could not get transform string from JoinerImage")
                return
            }
            
            imageView.transform = CGAffineTransformFromString(transform)
            imageView.horizontalConstraint.constant = CGFloat(joinerImage.xPosition)
            imageView.verticalConstraint.constant = CGFloat(joinerImage.yPosition)
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Could not get image from image picker")
            dismiss(animated: true, completion: nil)
            return
        }
        
        add(image: image)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
