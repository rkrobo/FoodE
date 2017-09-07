//
//  gridViewLayout.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-09-07.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit

class GridViewLayout: UICollectionViewFlowLayout {
    
     let itemHeight: CGFloat = 200
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
    
    func itemWidth() -> CGFloat {
        return (collectionView!.frame.width/2)-1
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(),height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(),height: itemHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}


