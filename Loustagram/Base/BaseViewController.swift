//
//  BaseViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/23/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BaseViewController: ASViewController<ASDisplayNode> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupBarButton(with image: UIImage, leftOfBar: Bool) {
        if leftOfBar {
            let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(leftBarButtonTap))
            navigationItem.leftBarButtonItem = button
        } else {
            let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightBarButtonTap))
            navigationItem.rightBarButtonItem = button
        }
    }
    
    @objc func rightBarButtonTap() {
        
    }
    
    @objc func leftBarButtonTap() {
        
    }
    
}
