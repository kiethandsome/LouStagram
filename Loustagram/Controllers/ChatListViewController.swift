//
//  ChatListViewController.swift
//  Loustagram
//
//  Created by Kiet on 12/23/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase

class ChatListViewController: ASViewController<ASTableNode> {

    var chats = [Chat]()
    var userChatsHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    
    init() {
        super.init(node: ASTableNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Messages"
        setupBarButtonItems()
        node.view.estimatedRowHeight = 71.0
        node.delegate = self
        node.dataSource = self
        node.view.tableFooterView = UIView()
        
        userChatsHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            DispatchQueue.main.async {
                self?.node.reloadData()
            }
        }
    }
    
    deinit {
        userChatsRef?.removeObserver(withHandle: userChatsHandle)
    }
    
    func setupBarButtonItems() {
        let rightBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTap))
        navigationItem.rightBarButtonItem = rightBtn
        
        let leftBtn = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(leftBarButtonTap))
        navigationItem.leftBarButtonItem = leftBtn
    }
    
    @objc func rightBarButtonTap() {
        let newChat = NewChatViewController()
        navigationController?.pushViewController(newChat, animated: true)
    }
    
    @objc func leftBarButtonTap() {
        dismiss(animated: true)
    }
}

extension ChatListViewController : ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let chat = chats[indexPath.row]
        let cell = ChatCell(chat: chat)
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController()
        chatVC.chat = chats[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

class ChatCell: ASCellNode {
    
    let titleNode = ASTextNode()
    let lastMessageNode = ASTextNode()
    
    let titleAtrr: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 17.0),
                                                      .foregroundColor: UIColor.black]
    
    let lastMessAtrr: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 14.0),
                                                        .foregroundColor: UIColor.lightGray]
    
    init(chat: Chat) {
        super.init()
        titleNode.attributedText = NSAttributedString(string: chat.title, attributes: titleAtrr)
        
        guard let lastMess = chat.lastMessage else { return }
        lastMessageNode.attributedText = NSAttributedString(string: lastMess, attributes: lastMessAtrr)
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10.0, justifyContent: .start, alignItems: .start, children: [titleNode, lastMessageNode])
        let edgeInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        return ASInsetLayoutSpec(insets: edgeInset, child: verticalSpec)
    }
}













