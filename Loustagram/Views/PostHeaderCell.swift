//
//  PostHeaderCell.swift
//  Loustagram
//
//  Created by Kiet on 12/7/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class PostHeaderCell: ASCellNode {
    
    var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
    
    var userPostName: ASTextNode = {
        let textNode = ASTextNode()
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.mgRegular,
                                                      .foregroundColor: UIColor.black]
        textNode.attributedText = NSAttributedString(string: User.current.username, attributes: attribute)
        return textNode
    }()
    
    var optionButton: ASButtonNode = {
        let button = ASButtonNode()
        button.setImage(#imageLiteral(resourceName: "btn_options_black"), for: .normal)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        return button
        
    }()
    
    @objc func optionButtonTapped() {
        if let closure = didTapOptionsButtonForCell {
            closure(self)
        }
    }
    
    override init() {
        super.init()
        optionButton.addTarget(self, action: #selector(optionButtonTapped), forControlEvents: .touchUpInside)
        automaticallyManagesSubnodes = true
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.boldSystemFont(ofSize: 16.0),
                                                      .foregroundColor: UIColor.black]
        userPostName.attributedText = NSAttributedString(string: User.current.username, attributes: attribute)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal, spacing: 40.0 , justifyContent: .spaceBetween, alignItems: .center, children: [userPostName, optionButton])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10) , child: horizontalStack)
    }
}














