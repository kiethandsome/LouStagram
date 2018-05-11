//
//  LoginViewController.swift
//  Loustagram
//
//  Created by Kiet on 11/30/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DynamicColor
import FirebaseAuthUI
import FirebaseDatabase
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI

typealias FIRUser = FirebaseAuth.User

public let openSansFont = UIFont(name: "OpenSans", size: 12) // Custom Font for our App.

class LoginViewController: ASViewController<ASDisplayNode> {
    
    let pinkNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = DynamicColor(hexString: "FF6A95")
        node.frame.origin = CGPoint(x: 0, y: 0)
        return node
    }()
    
    let titleNode: ASTextNode = {
        let tt = ASTextNode()
        let textAlignment = NSMutableParagraphStyle()
        textAlignment.alignment = .center
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 36),
                                                      .foregroundColor: UIColor.white,
                                                      .paragraphStyle: textAlignment]
        tt.attributedText = NSAttributedString(string: "Loustagram", attributes: attribute)
        return tt
    }()
    
    let textNode: ASTextNode = {
        let tt = ASTextNode()
        let textAlignment = NSMutableParagraphStyle()
        textAlignment.alignment = .center
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 15),
                                                      .foregroundColor: UIColor.white,
                                                      .paragraphStyle: textAlignment]
        tt.attributedText = NSAttributedString(string: "Sign up to see photos and videos from your friends", attributes: attribute)
        return tt
    }()
    
    let loginButton: ASButtonNode = {
        let button = ASButtonNode()
        let textAlignment = NSMutableParagraphStyle()
        textAlignment.alignment = .center
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 15),
                                                      .foregroundColor: UIColor.white,
                                                      .paragraphStyle: textAlignment]
        button.backgroundColor = DynamicColor(hexString: "3897F0")
        button.setAttributedTitle(NSAttributedString(string: "Register or Login", attributes: attribute), for: .normal)
        return button
    }()
    
    @objc func login() {
        print("tapped")
        
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        authUI.delegate = self
        
        // configure Auth UI for Facebook login and Google Login.
        let providers: [FUIAuthProvider] = [FUIFacebookAuth(), FUIGoogleAuth()]
        authUI.providers = providers
        
        let authVc = authUI.authViewController()
        self.present(authVc, animated: true, completion: nil)
    }
    
    init() {
        super.init(node: ASDisplayNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        node.backgroundColor = .white
        node.addSubnode(pinkNode)
        pinkNode.addSubnode(titleNode)
        pinkNode.addSubnode(textNode)
        node.addSubnode(loginButton)
        loginButton.addTarget(self, action: #selector(login), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pinkNode.frame.size = CGSize(width: self.node.bounds.width, height: 256.0)
        
        titleNode.frame = CGRect(x: 0, y: 70.0, width: view.bounds.width, height: 45.0)
        titleNode.view.center.x = pinkNode.view.center.x
        
        textNode.frame = CGRect(x: 0, y: 150.0, width: 230, height: 90.0)
        textNode.view.center.x = pinkNode.view.center.x
        
        loginButton.frame  = CGRect(x: 35, y: 281, width: view.bounds.width - 70, height: 44)
        loginButton.layer.cornerRadius = 15.0
        loginButton.clipsToBounds = true
    }

}

extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("handle user signup / login")
        
        guard let user = user
            else {return}
        
        UserService.showUser(forUID: user.uid) { (user) in
            if let user = user {
                print("welcome back \(user.username).")
                User.setCurrent(user, writeToUserDefalt: true)
                self.didLogin()
                
            } else {
                print("New User")
                let vc = CreateUsernameViewController()
                self.present(vc, animated: true)
            }
        }
    }
}

extension UIViewController {
    
    open func didLogin() {
        let tabController = BaseTabbarController()
        
        let homeVc = HomeViewController()
        let homeNav = BaseNavigationController(rootViewController: homeVc)
        
        let profileVC = BaseNavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem.image = #imageLiteral(resourceName: "tab_profile_black")
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)

        
        let unusedVc = UnusedViewController()
        tabController.viewControllers = [homeNav, unusedVc, profileVC]
        
        guard let window = UIApplication.shared.keyWindow
            else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabController
            window.makeKeyAndVisible()
        }, completion: { completed in
            // maybe do something here
        })

    }
}
















