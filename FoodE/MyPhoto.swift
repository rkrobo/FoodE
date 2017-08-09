//
//  MyPhoto.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-08-09.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//


import UIKit

class MyPhoto: UIViewController{
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image = UIImage()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(animated)
        
       imageView.image = image
        
        
    }
    
}
