//
//  FiindFriendViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/4/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import Foundation
import AsyncDisplayKit

class FindFriendViewController: ASViewController<ASTableNode> {
    
    var users = [User]()

    init() {
        super.init(node: ASTableNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Find Friends"
        node.view.separatorInset.left = 0.0
        node.allowsSelection = false
        node.leadingScreensForBatching = 3.0
        node.delegate = self
        node.dataSource = self
        node.view.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.node.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FindFriendViewController: ASTableDelegate, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = FindFriendCell()
        cell.delegate = self
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: FindFriendCell, indexPath: IndexPath) {
        let user = users[indexPath.row]
        cell.usernameNode.attributedText = NSAttributedString(string: user.username)
        cell.followButton.isSelected = user.isFollowed
    }
}

extension FindFriendViewController: FindFriendCellDelegate {
    func didTapOnCell(_ followButton: ASButtonNode, on cell: FindFriendCell) {
        guard let indexPath = node.indexPath(for: cell) else { return }
        
        followButton.isUserInteractionEnabled = false
        let followee = users[indexPath.row]
        
        FollowService.setIsFollowing(!followee.isFollowed, fromCurrentUserTo: followee) { (success) in
            defer {
                followButton.isUserInteractionEnabled = true
            }
            
            guard success else { return }
            
            followee.isFollowed = !followee.isFollowed
            self.node.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    

}





















