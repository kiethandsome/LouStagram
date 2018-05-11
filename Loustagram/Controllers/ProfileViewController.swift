//
//  ProfileViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/19/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import Kingfisher
import FirebaseAuth

class ProfileViewController: ASViewController<ASCollectionNode> {
    
    // MARK: - Properties
    
    var user: User!
    var posts = [Post]()
    var authHandle: AuthStateDidChangeListenerHandle?

    var profileHandle: DatabaseHandle = 0
    var profileRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        user = user ?? User.current
        navigationItem.title = user.username
        
        profileHandle = UserService.observeProfile(for: user) { [unowned self] (ref, user, posts) in
            self.profileRef = ref
            self.user = user
            self.posts = posts
            
            DispatchQueue.main.async {
                self.node.reloadData()
            }
        }
        node.delegate = self
        node.dataSource = self
        node.view.showsVerticalScrollIndicator = true
        node.view.isScrollEnabled = true
        
        authHandle = Auth.auth().addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil else { return }
            
            let loginViewController = LoginViewController()
            self.view.window?.rootViewController = loginViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    deinit {
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
        profileRef?.removeObserver(withHandle: profileHandle)
    }
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        super.init(node: ASCollectionNode(collectionViewLayout: flowLayout))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBarButtonItem() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "tab_find_friends_black"), style: .plain, target: self, action: #selector(barButtonTap))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func barButtonTap() {
        let findFriendVc  = FindFriendViewController()
        navigationController?.pushViewController(findFriendVc, animated: true)
    }
}

extension ProfileViewController: ASCollectionDelegate, ASCollectionDelegateFlowLayout, ASCollectionDataSource, ProfileHeaderNodeDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        var post: Post
        let itemWidth = self.node.bounds.width / 3 - 1
        let headerSize = CGSize(width: self.view.bounds.width, height: 150.0)

        if indexPath.item == 0 {
            let headerCell = ProfileHeaderNode(user: user, size: headerSize)
            headerCell.delegate = self
            return headerCell
        } else {
            post = posts[indexPath.item - 1]
        }
        let imageCell = ImageCell(post: post, size: CGSize(width: itemWidth, height: itemWidth))
        return imageCell
    }
    
    func didTapSettingsButton(_ button: ASButtonNode, on headerNode: ProfileHeaderNode) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
            print("log out user")
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                assertionFailure("Error signing out: \(error.localizedDescription)")
            }
        }
        alertController.addAction(signOutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}






//
protocol ProfileHeaderNodeDelegate: class {
    func didTapSettingsButton(_ button: ASButtonNode, on headerNode: ProfileHeaderNode)
}

class ProfileHeaderNode: ASCellNode {
    
    weak var delegate: ProfileHeaderNodeDelegate?
    
    let numberLabelAttr: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                                  .foregroundColor: UIColor.black]
    
    let textLabelAtrr: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 13.0),
                                                      .foregroundColor: UIColor.darkGray]
    
    let buttonTitleAtrr: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 15.0),
                                                      .foregroundColor: UIColor.black]
    
    let postsNode = ASTextNode()
    let postSNumber = ASTextNode()
    
    let followersNode = ASTextNode()
    let followerNumberNode = ASTextNode()
    
    let followingNode = ASTextNode()
    let followingNumerNode = ASTextNode()
    
    let settingButton: ASButtonNode = {
       let button = ASButtonNode()
        button.layer.cornerRadius = 10.0
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.8
        return button
    }()
    
    init(user: User, size: CGSize) {
        super.init()
        
        postsNode.attributedText = NSAttributedString(string: "Posts", attributes: textLabelAtrr)
        followersNode.attributedText = NSAttributedString(string: "Followers", attributes: textLabelAtrr)
        followingNode.attributedText = NSAttributedString(string: "Following", attributes: textLabelAtrr)
        
        let postCount = user.postCount ?? 0
        postSNumber.attributedText = NSAttributedString(string: "\(postCount)", attributes: numberLabelAttr)
        
        let followerCount = user.followerCount ?? 0
        followerNumberNode.attributedText = NSAttributedString(string: "\(followerCount)", attributes: numberLabelAttr)
        
        let followingCount = user.followingCount ?? 0
        followingNumerNode.attributedText = NSAttributedString(string: "\(followingCount)", attributes: numberLabelAttr)

        settingButton.setAttributedTitle( NSAttributedString(string: "Settings", attributes: buttonTitleAtrr), for: .normal)
        settingButton.addTarget(self, action: #selector(settingButtonTaps), forControlEvents: .allEvents)
        self.automaticallyManagesSubnodes = true
    }
    
    @objc func settingButtonTaps() {
        self.delegate?.didTapSettingsButton(settingButton, on: self)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        settingButton.style.preferredSize = CGSize(width: UIScreen.main.bounds.width - 50, height: 50.0)

        
        let postsStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 2.0,
                                           justifyContent: .center,
                                           alignItems: .center,
                                           children: [postSNumber, postsNode])
        let followersStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 2.0,
                                               justifyContent: .center,
                                               alignItems: .center,
                                               children: [followerNumberNode, followersNode])
        let followingStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 2.0,
                                               justifyContent: .center,
                                               alignItems: .center,
                                               children: [followingNumerNode, followingNode])
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 20.0,
                                                justifyContent: .center,
                                                alignItems: .center,
                                                children: [postsStack, followersStack, followingStack])
        let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                              spacing: 10.0,
                                              justifyContent: .start,
                                              alignItems: .center,
                                              children: [horizontalStack, settingButton])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20.0, left: 0, bottom: 20.0, right: 0), child: verticalStack)

    }
}

class ImageCell: ASCellNode {

    let imageView = UIImageView()
    
    init(post: Post, size: CGSize) {
        super.init()
        DispatchQueue.main.async {
            self.imageView.contentMode = .scaleToFill
            self.imageView.clipsToBounds = true
        }
        view.addSubview(imageView)
        view.addContraintsWithFormat(format: "V:|[v0]|", views: imageView)
        view.addContraintsWithFormat(format: "H:|[v0]|", views: imageView)
        imageView.kf.setImage(with: URL(string: post.imageURL))
        backgroundColor = .blue
        style.preferredSize = size
        

    }

    
}















