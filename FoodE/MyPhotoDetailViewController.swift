//
//  MyPhoto.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-08-09.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//


import UIKit

class MyPhotoDetailViewController: UIViewController{
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var restaurantName: UILabel!
    
    
    var image = UIImage()
    
    var restaurantNameText = String()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(animated)
        
        imageView.image = image
        
        restaurantName.text=restaurantNameText
        
    }
    
}
