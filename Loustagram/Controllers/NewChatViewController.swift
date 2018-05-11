//
//  NewChatViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/23/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class NewChatViewController: ASViewController<ASTableNode> {
    
    var following = [User]()
    var selectedUser: User?
    var existingChat: Chat?
    var nextButton = UIBarButtonItem()
    
    init() {
        super.init(node: ASTableNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.delegate = self
        node.dataSource = self
        node.view.estimatedRowHeight = 50.0
        navigationItem.title = "New Message"
        setupNextButton()
        UserService.following { [weak self] (following) in
            self?.following = following
            DispatchQueue.main.async {
                self?.node.reloadData()
            }
        }
    }
    
    func setupNextButton() {
        nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextt))
        navigationItem.rightBarButtonItem = nextButton
        nextButton.isEnabled = false

    }
    
    @objc func nextt() {
        guard let selectedUser = selectedUser else { return }
        nextButton.isEnabled = false
        ChatService.checkForExistingChat(with: selectedUser) { (chat) in
            self.nextButton.isEnabled = true
            self.existingChat = chat
        }
        let members = [selectedUser, User.current]
        let chatVc = ChatViewController()
        chatVc.chat = existingChat ?? Chat(members: members)
        navigationController?.pushViewController(chatVc, animated: true)
    }
}

extension NewChatViewController: ASTableDataSource  {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = NewChatUserCellNode()
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: NewChatUserCellNode, at indexPath: IndexPath) {
        let follower = following[indexPath.row]
        let buttonTitleAtrr: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 15.0),
                                                            .foregroundColor: UIColor.black]
        cell.textLabel.attributedText = NSAttributedString(string: follower.username, attributes: buttonTitleAtrr)
        
        if let selectedUser = selectedUser, selectedUser.uid == follower.uid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
}

extension NewChatViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableNode.nodeForRow(at: indexPath) else { return }
        selectedUser = following[indexPath.row]
        cell.accessoryType = .checkmark
        nextButton.isEnabled = true
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableNode.nodeForRow(at: indexPath) else { return }
        selectedUser = following[indexPath.row]
        cell.accessoryType = .none
    }
}

class NewChatUserCellNode: ASCellNode {
    
    let textLabel = ASTextNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 50) , child: textLabel)
    }
    
}











