 //
//  PostImageCell.swift
//  Loustagram
//
//  Created by Kiet on 12/7/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class PostImageCell: ASCellNode {
    
    let width = UIScreen.main.bounds.width
    
    var node1 = ASDisplayNode()
    
    init(post: Post) {
        super.init()
        
        DispatchQueue.main.sync {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
            imageView.kf.setImage(with: URL(string: post.imageURL))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            node1.view.addSubview(imageView)
            automaticallyManagesSubnodes = true
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        node1.style.preferredSize = CGSize(width: width, height: width)
        return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0), child: node1)
    }
    
    
}
