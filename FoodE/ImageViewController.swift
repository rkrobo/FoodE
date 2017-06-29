
//
//  ImageView.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-25.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    var foodPhoto:Photos!
    
     override func viewDidLoad() {

        imageView.image = UIImage(data: foodPhoto.imageData! as Data)
    }
}
