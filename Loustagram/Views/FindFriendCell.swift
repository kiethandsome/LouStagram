//
//  FindFriendCell.swift
//  Loustagram
//
//  Created by Kiet on 12/12/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol FindFriendCellDelegate: class {
    func didTapOnCell(_ followButton: ASButtonNode, on cell: FindFriendCell)
}

class FindFriendCell: ASCellNode {
    
    weak var delegate: FindFriendCellDelegate?
    
    var usernameNode: ASTextNode = {
        let tn = ASTextNode()
        return tn
    }()
    
    var followButton: ASButtonNode = {
        let btn = ASButtonNode()
        
        btn.setTitle("Follow", with: UIFont.systemFont(ofSize: 15.0), with: .blue, for: .normal)
        btn.setTitle("Following", with: .systemFont(ofSize: 14.0), with: .blue, for: .selected)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.clipsToBounds = true
        
        return btn
    }()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        followButton.addTarget(self, action: #selector(follow), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    
    @objc func follow() {
        self.delegate?.didTapOnCell(followButton, on: self)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        followButton.style.preferredSize = CGSize(width: 115.0, height: 51.0)
        followButton.style.alignSelf = .end
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 30.0,
                                                justifyContent: .spaceBetween,
                                                alignItems: .center,
                                                children: [usernameNode, followButton])
        
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) , child: horizontalStack)
    }
}
