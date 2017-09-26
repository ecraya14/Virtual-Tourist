//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by ecraya14 on 31/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if photo.image == nil {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
