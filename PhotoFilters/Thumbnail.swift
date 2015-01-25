// ---------------------------------------------------------------------------------------------------------------
//  Thumbnail.swift
//  PhotoFilters
//
//  Created by Gru on 01/12/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//
//

import UIKit

class Thumbnail {

    let DBUG  = true

    var originalImage : UIImage?
    var filteredImage : UIImage?
    var filterName    : String
    var imageQueue    : NSOperationQueue
    var gpuContext    : CIContext
    
    // ---------------------------------------------------------------------------------------------------------
    // Function: init()
    //
    init( filterName : String, operationQueue : NSOperationQueue, context : CIContext) {
        self.filterName = filterName
        self.imageQueue = operationQueue
        self.gpuContext = context
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: generateFilteredImage()
    //
    func generateFilteredImage() {
        if DBUG { println( "generateFilteredImage() - " + self.filterName + " " ) }
        let startImage     = CIImage(image: self.originalImage)
        let filter         = CIFilter(name: self.filterName)
            filter.setDefaults()
            filter.setValue(startImage, forKey: kCIInputImageKey)
        let result         = filter.valueForKey(kCIOutputImageKey) as CIImage
        let extent         = result.extent()
        let imageRef       = self.gpuContext.createCGImage(result, fromRect: extent)
        self.filteredImage = UIImage( CGImage: imageRef )
    }
}