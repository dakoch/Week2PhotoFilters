//
//  GalleryCell.swift
//  PhotoFilters
//
//  Created by Gru on 01/12/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    let imageView = UIImageView()
  
    override init(frame: CGRect) {

        super.init(frame: frame)

        self.addSubview(self.imageView)
        self.backgroundColor = UIColor.grayColor()

        imageView.frame                 = self.bounds
        imageView.contentMode           = UIViewContentMode.ScaleAspectFill
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.layer.masksToBounds   = true

        let  views = ["imageView" : imageView]
        let  imageViewConstraintsHorizontal =
                NSLayoutConstraint.constraintsWithVisualFormat( "H:|[imageView]|", options: nil, metrics: nil, views: views )
        self.addConstraints(imageViewConstraintsHorizontal)

        let  imageViewConstraintsVertical =
                NSLayoutConstraint.constraintsWithVisualFormat( "V:|[imageView]|", options: nil, metrics: nil, views: views )
        self.addConstraints(imageViewConstraintsVertical)

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
