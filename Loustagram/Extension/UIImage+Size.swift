//
//  UIImage+Size.swift
//  Loustagram
//
//  Created by Kiet on 12/7/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
}
