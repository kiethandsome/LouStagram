//
//  AppDelegate.swift
//  Loustagram
//
//  Created by Kiet on 11/30/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import Firebase
import AsyncDisplayKit
import FBSDKCoreKit
import FirebaseAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate().application(application, didFinishLaunchingWithOptions: launchOptions)
        setupRootView(for: window)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        
        // other URL handling goes here
        
        return false
    }
    
    func setupLoginScreen() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let rootvc = LoginViewController()
        let nav = UINavigationController(rootViewController: rootvc)
        nav.isNavigationBarHidden = true
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupMainScreen() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tabController = BaseTabbarController()
        
        let homeVc = HomeViewController()
        let homeNav = BaseNavigationController(rootViewController: homeVc)
        
        let profileVC = BaseNavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem.image = #imageLiteral(resourceName: "tab_profile_black")
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)

        
        let didUsedVc = UnusedViewController()
        tabController.viewControllers = [homeNav, didUsedVc, profileVC]
        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()
    }
    
    func setupRootView(for window: UIWindow?) {
        let defaults = UserDefaults.standard
        
        if Auth.auth().currentUser != nil,  // if user is exsisted
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
                User.setCurrent(user)
            print("user was Exsisted, name: \(user.username)")
            setupMainScreen()
        } else {
            print("User doesnt exsisted!")
            setupLoginScreen()
        }
    }



}

