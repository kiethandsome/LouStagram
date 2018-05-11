//
//  BaseTabbarController.swift
//  Loustagram
//
//  Created by Kiet on 12/4/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit

class BaseTabbarController: UITabBarController {
    
    let photoHelper = MGPhotoHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoHelper.completionHandler = { image in
            print("hanle image")
            if #available(iOS 10.0, *) {
                PostService.create(for: image)
            } else {
                
            }
        }
        tabBar.isTranslucent = false
        delegate = self
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = .gray
            tabBar.tintColor = .black
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BaseTabbarController: UITabBarControllerDelegate {
    
    /// call this function to implement the action when tap on the camera tabbar item
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            
            photoHelper.presentActionSheet(from: self)
            
            print("taking photos")
            return false
        } else {
            return true
        }
    }
}





