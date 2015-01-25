// ---------------------------------------------------------------------------------------------------------
//  MetaDataViewController.swift
//  PhotoFilters
//
//  Created by Gru on 01/15/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//

import UIKit

class MetaDataViewController: UIViewController {

    let DBUG    = true
    var photo         : UIImage!
    
    var delegate : ImageSelectedProtocol?

    init( photo : UIImage ) {
       super.init()
       self.photo = photo
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: loadView()
    //
    override func loadView() {

    }

    // ---------------------------------------------------------------------------------------------------------
    // Function: viewDidLoad()
    //
    override func viewDidLoad() {
            super.viewDidLoad()
    }

}
