//
//  PostActionCell.swift
//  Loustagram
//
//  Created by Kiet on 12/8/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: ASButtonNode, on cell: PostActionCell)
}

class PostActionCell: ASCellNode {
    
    weak var delegate: PostActionCellDelegate?
    
    var didTapLikeButton: ((_ button: ASButtonNode, _ cell: PostActionCell) -> Void)?
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    var likeButtonNode: ASButtonNode = {
       let iv = ASButtonNode()
        iv.setImage(#imageLiteral(resourceName: "btn_heart_black_outline"), for: .normal)
        iv.setImage(#imageLiteral(resourceName: "btn_heart_red_solid"), for: .selected)
        iv.isUserInteractionEnabled = true
        return iv
    }()

    var dateNode: ASTextNode = {
        let dn = ASTextNode()
        return dn
    }()
    
    var numberLikeNode: ASTextNode = {
        let textNode = ASTextNode()

        return textNode
    }()
    
    init(post: Post) {
        super.init()
        configureCell(with: post)
        likeButtonNode.addTarget(self, action: #selector(likeButtonTapped), forControlEvents: ASControlNodeEvent.touchUpInside)
        automaticallyManagesSubnodes = true
        frame.size.height = 46.0
    }
    
    func configureCell(with post: Post) {
        likeButtonNode.isSelected = post.isLiked
        let attribute: [NSAttributedStringKey:Any] = [.font: UIFont.systemFont(ofSize: 10),
                                                      .foregroundColor: UIColor.black]
        dateNode.attributedText = NSAttributedString(string: timestampFormatter.string(from: post.creationDate) , attributes: attribute)
        
        numberLikeNode.attributedText = NSAttributedString(string: "\(post.likeCount) likes", attributes: attribute)
    }
    
    @objc func likeButtonTapped() {
        if let closure = self.didTapLikeButton {
            closure(self.likeButtonNode, self)
        }
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        likeButtonNode.style.preferredSize = CGSize(width: 20.0, height: 20.0)
        
        let littleStack = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 10.0,
                                            justifyContent: .start,
                                            alignItems: .center,
                                            children: [likeButtonNode, numberLikeNode])
        
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 40.0 ,
                                                justifyContent: .spaceBetween,
                                                alignItems: .center,
                                                children: [littleStack, dateNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10.0, left: 10, bottom: 15, right: 10) , child: horizontalStack)
    }
}









