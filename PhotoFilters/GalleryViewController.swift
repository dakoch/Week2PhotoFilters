//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by Gru on 01/12/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//


import UIKit

protocol ImageSelectedProtocol {
    func controllerDidSelectImage(selectedImage: UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var DBUG = true

    var collectionView : UICollectionView!
    var delegate       : ImageSelectedProtocol?
    var collectionViewFlowLayout : UICollectionViewFlowLayout!

    var images = [UIImage]()

    override func loadView() {
        let  rootView                   = UIView(frame: UIScreen.mainScreen().bounds)

        let  collectionViewFlowLayout          = UICollectionViewFlowLayout()
             collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)

        self.collectionView             = UICollectionView( frame: rootView.frame,
                                             collectionViewLayout: collectionViewFlowLayout)
        self.collectionView.dataSource  = self
        self.collectionView.delegate    = self

        rootView.addSubview( self.collectionView )

        self.view = rootView
    }

    // DONE/TODO: Create utility to get images off of my machine...
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGrayColor()
        self.collectionView.registerClass( GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL" )

        loadImages( images )

        let pinchRecognizer = UIPinchGestureRecognizer( target: self, action: "collectionViewPinched:" )
        self.collectionView.addGestureRecognizer(pinchRecognizer)

        // Do any additional setup after loading the view.
    }
  
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    // Builds the 'Gallery' of photos
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if DBUG { println("collectionView indexPath[\(indexPath.row)] ") }
        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        let image = self.images[indexPath.row]
        cell.imageView.image = image

        return cell
    }

/*  func collectionView( collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        //    let image = self.images[indexPath.row]
        //    cell.imageView.image = image
        cell.backgroundColor = UIColor.redColor()
        return cell
    } */


    // Image selected from the gallery, at 'indexPath.row'
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if DBUG { println( "collectionView indexPath[\(indexPath.row)] ") }
        self.delegate?.controllerDidSelectImage( self.images[indexPath.row] )
        self.navigationController?.popViewControllerAnimated(true)
    }

    //MARK: Gesture Recognizer Actions

    func collectionViewPinched(sender : UIPinchGestureRecognizer) {

        switch sender.state {
        case .Began:
            println("began")
        case .Changed:
            println("changed with velocity \(sender.velocity)")
        case .Ended:
            println("ended")
            self.collectionView.performBatchUpdates({ () -> Void in
                if sender.velocity > 0 {
                    //increase item size
                    let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width * 2, height: self.collectionViewFlowLayout.itemSize.height * 2)
                    self.collectionViewFlowLayout.itemSize = newSize
                } else if sender.velocity < 0 {
                    let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width / 2, height: self.collectionViewFlowLayout.itemSize.height / 2)
                    self.collectionViewFlowLayout.itemSize = newSize
                    //decrease item size
                }


                }, completion: {(finished) -> Void in
                    
            })
            
        default:
            println("default")
        }
        println("collection view pinched")
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func loadImages( images: [UIImage] ) {

        let image1 = UIImage(named: "photo-1b.jpeg")
        let image2 = UIImage(named: "photo-1c.jpeg")
        let image3 = UIImage(named: "photo-1d.jpeg")
        let image4 = UIImage(named: "ios01.tiff")

        let image5 = UIImage(named: "IOS02.tiff")
        let image6 = UIImage(named: "iOS03.tiff")
        let image7 = UIImage(named: "iOS05.tiff")
        let image8 = UIImage(named: "IOS06.tiff")
        let imageA = UIImage(named: "tagTypeController.JPG")

        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        self.images.append(image5!)
        self.images.append(image6!)
        self.images.append(image7!)
        self.images.append(image8!)
        self.images.append(imageA!)
    }
}
