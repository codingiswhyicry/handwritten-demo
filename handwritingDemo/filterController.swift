//
//  filterController.swift
//  handwritingDemo
//
//  Created by Amanda Southworth on 9/24/17.
//  Copyright © 2017 Amanda Southworth. All rights reserved.
//

import UIKit
import FlexibleImage

class filterController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image1
    }
    
    var image1 = #imageLiteral(resourceName: "handwriting")
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBAction func filterAction(_ sender: Any) {
        
        let pipeline_f = ImagePipeline()
            .contrast()
            .invert()
            .hardMix(color: UIColor.darkGray)
        
        let new_image = pipeline_f.image(image1)
        imageView.image = new_image!
    }
}
