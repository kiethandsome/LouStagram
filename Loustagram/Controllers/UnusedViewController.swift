//
//  UnusedViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/4/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit

class UnusedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.image = #imageLiteral(resourceName: "tab_plus_black")
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        tabBarItem.tag = 1

    }
}
