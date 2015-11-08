//
//  PostsTableViewController.swift
//  
//
//  Created by Jesse Sipola on 6.11.2015.
//  Copyright © 2015 . All rights reserved.
//

import UIKit

class ShowPostsTableViewController: UITableViewController {

    var posts: [Post] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        let query = LBQuery(className: "Post")
        //query.whereKeyEquals("name", value: "something")
        //query.whereKeyEquals("post", value: "something")
        query.fetchResultsInBackground {
            (results, error) -> Void in
            if error == nil {
                if let posts = results as? [Post] {
                    self.posts = posts
                }
            } else {
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func initializePostCell(cell: PostTableViewCell, post: Post) {
        func setName() {
            cell.nameLabel.text = post.name
        }
        
        func setPost() {
            cell.postLabel.text = post.post
        }
        
        setName()
        setPost()
    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> PostTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post") as! PostTableViewCell
        initializePostCell(cell, post: posts[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)
    }

}
