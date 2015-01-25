//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Gru on 01/12/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//
// (1A) Added button for 'FACTS' button.
//
// W2.D2.02[x] Setup a collection view to show filtered thumbnails of the image
// W2.D2.04[*] Following my (insane) workflow for applying filters to the thumbnails.
//                  Don't worry if you don't get it 100%, we will spend a lot of
//                  time tomorrow going over it and refining it. Good luck

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let DBUG = true

    let alertController = UIAlertController(   title: "Welcome to PhotoFilter",
                                             message: "Select Gallery to get a list of images that can be edited",
                                      preferredStyle: UIAlertControllerStyle.ActionSheet )

    var photoSelected = false
    var imageSelected : UIImage!
    var filterID      = -1

    let mainImageView = UIImageView()
    let metaDataView  = UIImageView()

    var collectionView            : UICollectionView!
    var collectionViewYConstraint : NSLayoutConstraint!

    var gpuContext                : CIContext!

    var originalThumbnail         : UIImage!
    var thumbnails  = [Thumbnail]()

    var filterNames = [String]()
    let imageQueue  = NSOperationQueue()

    var  doneButton : UIBarButtonItem!
    var shareButton : UIBarButtonItem!
    var factsButton : UIBarButtonItem!    // (1A)

    // ---------------------------------------------------------------------------------------------------------
    //  Function: loadView()
    //
    override func loadView() {

        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
            rootView.backgroundColor = UIColor.grayColor()
            rootView.addSubview(self.mainImageView)

        // Setting up the first view page
        self.mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.mainImageView.backgroundColor   = UIColor.grayColor()
        self.mainImageView.layer.borderColor = UIColor.blackColor().CGColor;
        self.mainImageView.layer.borderColor = UIColor.lightGrayColor().CGColor;
        self.mainImageView.layer.borderWidth = 0.28

//    self.metaDataView.

    // Setup 'Photos' button.
        let photoButton = UIButton()
            photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            photoButton.setTitle("Photos", forState: .Normal)
            photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)

            rootView.addSubview(photoButton)

        // W2.D2.02[x] Setup a collection view to show filtered thumbnails of the image
        // Setting up the horizontal collection of thumbnails w/ some sample filters applied
        let  collectionviewFlowLayout = UICollectionViewFlowLayout()
             collectionviewFlowLayout.itemSize = CGSize(width: 100, height: 100)
             collectionviewFlowLayout.scrollDirection = .Horizontal

        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionviewFlowLayout)

             collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
             collectionView.dataSource = self
             collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")

             rootView.addSubview(collectionView)
    
        let views = [    "photoButton" : photoButton,
                       "mainImageView" : self.mainImageView,
                      "collectionView" : collectionView,
                        "metaDataView" : metaDataView]
    
        self.setupConstraintsOnRootView(rootView, forViews: views)
    
        self.view = rootView
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: viewDidLoad()
    //
    override func viewDidLoad() {

        super.viewDidLoad()

        //  DONE button
        self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")

        //  SHARE button
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")

        //  FACTS button (1A)
        self.factsButton = UIBarButtonItem( title: "Facts",
                             style: UIBarButtonItemStyle.Plain, target: self, action: "factsPressed")

        //  Setup for the 'Navigation' bar, adding the 'FACTS' and 'SHARE' button(s)
        self.navigationItem.rightBarButtonItem = self.shareButton
        self.navigationItem.leftBarButtonItem  = self.factsButton       // (1A)
        self.navigationItem.rightBarButtonItem = self.doneButton

// GALLERY option...
        // W2.D2.01[x] Setup your custom protocol & delegate, which will allow your gallery view
        //                  controller to communicate back to the home view controller which
        //                  image was selected from the gallery
        let galleryOption = UIAlertAction( title: "Gallery", style: UIAlertActionStyle.Default ) { (action) -> Void in
            if self.DBUG { println("gallery pressed") }
            let galleryVC = GalleryViewController()
                galleryVC.delegate = self

            self.navigationController?.pushViewController(galleryVC, animated: true)
        }
        self.alertController.addAction(galleryOption)

// FILTER option
        let filterOption = UIAlertAction( title: "Filter", style: UIAlertActionStyle.Default ) { (action) -> Void in

            if self.DBUG { println("filter pressed") }

            self.collectionViewYConstraint.constant = 20
            UIView.animateWithDuration( 0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        self.alertController.addAction(filterOption)

// META DATA option.....
        let metaDataOption = UIAlertAction( title: "Meta Data", style: UIAlertActionStyle.Default ) { (action) -> Void in
            if self.DBUG { println( "meta data pressed" ) }
            self.collectionViewYConstraint.constant = 20
            UIView.animateWithDuration( 0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        self.alertController.addAction(metaDataOption)

// CAMERA option...
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera ) {
            let cameraOption = UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
        
                let imagePickerController = UIImagePickerController()
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                    imagePickerController.allowsEditing = true
                    imagePickerController.delegate = self
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            })
            self.alertController.addAction(cameraOption)
        }
    
        let photoOption = UIAlertAction(title: "Photos", style: .Default) { (action) -> Void in
            let photosVC = PhotosViewController()
            photosVC.destinationImageSize = self.mainImageView.frame.size
            photosVC.delegate = self
            self.navigationController?.pushViewController(photosVC, animated: true)
        }
    
        self.alertController.addAction(photoOption)

        let options = [kCIContextWorkingColorSpace : NSNull()] // helps keep things fast
//      let EAGLContext = EAGLContext( EAGLRenderingAPI.OpenGLES2)
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
        self.setupThumbnails()

        // Do any additional setup after loading the view, typically from a nib.

        self.logAllFilters()
    }

    func logAllFilters() {
        let properties = CIFilter.filterNamesInCategory(kCICategoryBuiltIn)
        println(properties)

        for filterName: AnyObject in properties {
            let fltr = CIFilter(name:filterName as String)
            println(fltr.attributes())
        }
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: setupThumbnails()
    //
    // ------------------------------------------------------------------------------------------------------
    // W2.D2.04[x] Following my (insane) workflow for applying filters to the thumbnails.
    //                  Don't worry if you don't get it 100%, we will spend a lot of
    //                  time tomorrow going over it and refining it. Good luck
    /* https:// developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CITwirlDistortion   */
    func setupThumbnails() {

        self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CICircularScreen", "CIColorCube"]
        for name in self.filterNames {

            var thumbnail = Thumbnail( filterName: name, operationQueue: self.imageQueue, context: self.gpuContext )

            if name == "CITwirlDistortion" {
                //  thumbnail = Thumbnail( filterName: name, operatiITwirlDistortion",
            }
            self.thumbnails.append( thumbnail )
        }
    }
 

    // ---------------------------------------------------------------------------------------------------------
    // Function: viewDidLoad()
    //
    // MARK: ImageSelectedDelegate
    func controllerDidSelectImage(image: UIImage) {

        if DBUG { println("image selected") }
        self.mainImageView.image = image
        self.generateThumbnail(image)
    
        for thumbnail in self.thumbnails {
            thumbnail.originalImage = self.originalThumbnail
            thumbnail.filteredImage = nil
        }
        photoSelected = true
        imageSelected = image           // This should be the image displayed in the 
                                        // view page after being picked from the gallery....

        self.collectionView.reloadData()
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: imagePickerController()
    //
    // MARK: UIImagePickerController
    func imagePickerController( picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        println( "imagePickerController" )
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.controllerDidSelectImage(image!)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: imagePickerControllerDidCancel()
    //
    // CANCEL
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
  
    //MARK: Button Selectors
    func photoButtonPressed(sender : UIButton) {
        println( "photoButtonPressed()" )
        self.presentViewController(self.alertController, animated: true, completion: nil)
    }

    // ---------------------------------------------------------------------------------------------------------
    //    Function: generateThumbnail()
    // Description: Utility method to create a thumbnail version of the original selected image
    func generateThumbnail( originalImage: UIImage ) {

        println( "generateThumbnail()" )
        let size = CGSize(width: 100, height: 100)

        UIGraphicsBeginImageContext(size)
            originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
            self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
  
    // ---------------------------------------------------------------------------------------------------------
    // Function: donePressed()
    //
    func donePressed() {
        self.collectionViewYConstraint.constant = -120
        UIView.animateWithDuration( 0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.navigationItem.rightBarButtonItem = self.shareButton
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: sharePressed()
    //
    func sharePressed() {
        if SLComposeViewController.isAvailableForServiceType( SLServiceTypeTwitter ) {
            let compViewController = SLComposeViewController( forServiceType: SLServiceTypeTwitter )
                compViewController.addImage(self.mainImageView.image)
            self.presentViewController( compViewController, animated: true, completion: nil )
        } else {
            //tell user to sign into to twitter to use this feature
        }
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: factsPressed()
    //
    func factsPressed() {
        if DBUG { println( "factsPressed" ) }
        /*
        if self.photoSelected {
            let metaDataViewController = MetaDataViewController( photo: self.mainImageView.image! )
            var detailPopover : UIPopoverPresentationController =
                            .popoverPresentationController!
            detailPopover.barButtonItem( factsButton )
            detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
            metaDataViewController( mainImageView, animated: true, completion: nil )

        } else {

        }
        */
    }
  
    // MARK: UICollectionViewDataSource
    func collectionView( collectionView: UICollectionView, numberOfItemsInSection section: Int ) -> Int {
        println( self.thumbnails.count )
        return   self.thumbnails.count
    }

    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let cell          = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
        let thumbnail     = self.thumbnails[indexPath.row]
            self.filterID = indexPath.row
            println( "filter indexID[\(self.filterID)]" )

        if thumbnail.originalImage != nil {
            if thumbnail.filteredImage == nil {
                thumbnail.generateFilteredImage()
                cell.imageView.image = thumbnail.filteredImage!
            }
        }
        return cell
    }
  
    // MARK: Autolayout Constraints
    func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {

        let photoButtonConstraintVertial = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "V:[photoButton]-20-|",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                      views: views )
        rootView.addConstraints(photoButtonConstraintVertial)

        let photoButton = views["photoButton"] as UIView!
        let photoButtonConstraintHorizontal = NSLayoutConstraint( item: photoButton,
                                                             attribute: .CenterX,
                                                             relatedBy: NSLayoutRelation.Equal,
                                                                toItem: rootView,
                                                             attribute: NSLayoutAttribute.CenterX,
                                                            multiplier: 1.0, constant: 0.0)
        rootView.addConstraint(photoButtonConstraintHorizontal)

        photoButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)

// Horizontal
        let mainImageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "H:|-[mainImageView]-|",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                    views: views )
        rootView.addConstraints(mainImageViewConstraintsHorizontal)

// Vertical
        let mainImageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "V:|-80-[mainImageView]-30-[photoButton]",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                    views: views )
        rootView.addConstraints(mainImageViewConstraintsVertical)
    
// Horizontal - collectionView
        let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "H:|[collectionView]|",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                    views: views )
        rootView.addConstraints(collectionViewConstraintsHorizontal)

// Height
        let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "V:[collectionView(100)]",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                    views: views )
        self.collectionView.addConstraints(collectionViewConstraintHeight)

// Vertical
        let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat(
                                                                    "V:[collectionView]-(-120)-|",
                                                                    options: nil,
                                                                    metrics: nil,
                                                                    views: views )
        rootView.addConstraints(collectionViewConstraintVertical)

        self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint
    }

    // ---------------------------------------------------------------------------------------------------------
    //  Function: displayFacts()
    //
    func displayFacts( sender: UIBarButtonItem ) {
        if self.DBUG { println( "display facts" ) }
    }
}

