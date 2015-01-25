// ---------------------------------------------------------------------------------------------------------
//
//  PhotosViewController.swift
//  PhotoFilters
//
//  Created by Gru on 01/12/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let DBUG = true

    var assetsFetchResults   : PHFetchResult!
    var assetCollection      : PHAssetCollection!
    var collectionView       : UICollectionView!
    var destinationImageSize : CGSize!
  
    var delegate : ImageSelectedProtocol?

    var imageManager    = PHCachingImageManager()

    // ---------------------------------------------------------------------------------------------------------
    // Function: loadView()
    //
    override func loadView() {

        let rootView = UIView( frame: UIScreen.mainScreen().bounds )

//      let flowlayout = UICollectionViewFlowLayout()
        self.collectionView     = UICollectionView( frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout() )
             collectionView.setTranslatesAutoresizingMaskIntoConstraints( false )
    
        let flowLayout          = collectionView.collectionViewLayout as UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 100, height: 100)

            rootView.addSubview( collectionView )

        self.view = rootView
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: viewDidLoad()
    //
    override func viewDidLoad() {

        super.viewDidLoad()
        self.imageManager       = PHCachingImageManager()
        self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate   = self
        self.collectionView.registerClass( GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL" )

        // Do any additional setup after loading the view.
    }

    //MARK: UICollectionViewDataSource
    // ---------------------------------------------------------------------------------------------------------
    // Function: collectionView() - numberOfItemsInSection
    //
    func collectionView( collectionView: UICollectionView, numberOfItemsInSection section: Int ) -> Int {

        if DBUG { println( "PhotosViewController - numberOfItemsInSection, indexPath[\(self.assetsFetchResults.count)] ") }
        return self.assetsFetchResults.count
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: collectionView() - cellForItemAtIndexPath
    //
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {

        if DBUG { println( "PhootosViewController - cellForItemAtIndexPath, indexPath[\(indexPath.row)] ") }

        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier( "PHOTO_CELL", forIndexPath: indexPath ) as GalleryCell
        let asset = self.assetsFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset( asset, targetSize: CGSize( width: 100, height: 100 ),
                                                      contentMode: PHImageContentMode.AspectFill,
                                                          options: nil )
        { (requestedImage, info) -> Void in cell.imageView.image = requestedImage }
    
        return cell
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: collectionView() - didSelectItemAtIndexPath
    //
    func collectionView( collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath ) {

        if DBUG { println( "PhotosViewController - didSelectItemAtIndexPath indexPath[\(indexPath.row)] ") }

        let selectedAsset = self.assetsFetchResults[indexPath.row] as PHAsset

        self.imageManager.requestImageForAsset( selectedAsset, targetSize: self.destinationImageSize,
                                    contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
            println() // DO NOT REMOVE - This is purely for the xcode one line closure bug
            self.delegate?.controllerDidSelectImage( requestedImage )
            self.navigationController?.popToRootViewControllerAnimated( true )
        }
    }
}
