//
//  AuthViewController.swift
//  Loustagram
//
//  Created by Kiet on 11/30/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import Foundation
import AsyncDisplayKit
import Kingfisher

class HomeViewController: ASViewController<ASTableNode> {
    
    let paginationHelper = MGPaginationHelper<Post>(serviceMethod: UserService.timeline)
    
    let refreshControl = UIRefreshControl()
    var posts = [Post]()
    
    init() {
        super.init(node: ASTableNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Loustagram"
        self.navigationController?.tabBarItem.image = #imageLiteral(resourceName: "tab_home_black")
        self.navigationController?.tabBarItem.imageInsets = UIEdgeInsets(top: 7, left: 0, bottom: -7, right: 0)
        configTableNode()
        reloadTimeline()
        setupMessageButton()
    }
    
    func setupMessageButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_mess"), style: .plain, target: self, action: #selector(messsageButtonTap))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func messsageButtonTap() {
        let messVc = ChatListViewController()
        let nav = BaseNavigationController(rootViewController: messVc)
        present(nav, animated: true)
    }
    
    func configTableNode() {
        node.allowsSelection = false
        node.delegate = self
        node.dataSource = self
        node.view.separatorStyle = .none
        node.view.tableFooterView = UIView()
        node.contentInset.top = 10.0
        
        /// add pull to refresh
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        node.view.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline() {
        self.paginationHelper.reloadData { [unowned self] (posts) in
            self.posts = posts
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.node.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}


extension HomeViewController: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.section]
        
        switch indexPath.row {
            
        case 0:
            let cellNodeBlock: ASCellNodeBlock = {
                let cellNode = PostHeaderCell()
                cellNode.userPostName.attributedText = NSAttributedString(string: post.poster.username)
                cellNode.didTapOptionsButtonForCell = { postHeaderCell in
                    self.handleOptionsButtonTap(from: postHeaderCell)
                }
                return cellNode
            }
            return cellNodeBlock
            
        case 1:
            let cellNodeBlock: ASCellNodeBlock = {
                let cellNode = PostImageCell(post: post)
                return cellNode
            }
            return cellNodeBlock
            
        case 2:
            let cellNodeBlock: ASCellNodeBlock = {
                let cellNode = PostActionCell(post: post)
                cellNode.didTapLikeButton = { (likeButton, postActionCell) in
                    self.handleLikeButtonTap(likeButton: likeButton, on: postActionCell)
                }
                return cellNode
            }
            return cellNodeBlock
            
        default:
            let nodeBlock : ASCellNodeBlock = {
                return ASCellNode()
            }
            return nodeBlock
        }
    }

    func tableView(_ tableView: ASTableView, willDisplayNodeForRowAt indexPath: IndexPath) {
        if indexPath.section >= posts.count - 1 {
            paginationHelper.paginate(completion: { [unowned self] (posts) in
                self.posts.append(contentsOf: posts)
                
                DispatchQueue.main.async {
                    self.node.reloadData()
                }
            })
        }
    }
    
    func handleOptionsButtonTap(from cell: PostHeaderCell) -> Void {
        guard let indexPath = cell.indexPath else { return }
        let post = posts[indexPath.section]
        let poster = post.poster
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if poster.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                print("report post")
                PostService.flag(post)
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            alertController.addAction(flagAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleLikeButtonTap(likeButton: ASButtonNode, on cell: PostActionCell) {
        print("did tap liked Button node")
        guard let indexPath = node.indexPath(for: cell)
            else {return}
        
        // Set the isUserInteractionEnabled property of the UIButton to false so the user doesn't accidentally send multiple requests by tapping too quickly
        likeButton.isUserInteractionEnabled = false
        let post = posts[indexPath.section]
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            
            // Use defer to set isUserInteractionEnabled to true whenever the closure returns
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            guard success else {return}
            
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            guard let cell = self.node.nodeForRow(at: indexPath) as? PostActionCell
                else {return}
            
            DispatchQueue.main.async {
                cell.configureCell(with: post)
            }
        }
        
    }
    
}




















