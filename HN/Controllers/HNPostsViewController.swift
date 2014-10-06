//
//  HNPostsViewController.swift
//  HN
//
//  Created by Ben Gordon on 9/8/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNPostsViewController: HNViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, HNPostsCellDelegate {
    
    // Properties
    @IBOutlet weak var postsTableView: UITableView!
    var currentPostType: PostFilterType = PostFilterType.Top
    var currentPosts: [HNPost] = []
    var isLoadingPosts: Bool = false
    var user: String? = nil

    // Init
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, postType: PostFilterType!) {
        currentPostType = postType
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, username: String) {
        user = username
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        buildUI()
        resetUI()
        menuType = .AllPosts
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserverForName(HNMarkAsReadDidChangeNotification, object: nil, queue: nil) {[weak self] (note) -> Void in
            if (self != nil) {
                self!.postsTableView.reloadData()
            }
        }
        
        // Load Data
        if (user != nil) {
            loadPosts(user!)
            return
        }
        
        loadPosts()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        bindNavigationBarToScrollView(postsTableView)
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UI
    func buildUI() {
        // Table View
        postsTableView.registerNib(UINib(nibName: BGUtils.className(HNPostsCollectionCell), bundle: nil), forCellReuseIdentifier: HNPostsCollectionCellIdentifier)
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.estimatedRowHeight = 72.0
        postsTableView.separatorInset = UIEdgeInsetsZero
        if (postsTableView.respondsToSelector(Selector.convertFromStringLiteral("layoutMargins"))) {
            postsTableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func resetUI() {
        super.resetUI()
        
        // Table
        postsTableView.separatorColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.CellSeparator)
        postsTableView.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        postsTableView.reloadData()
    }

    
    // Load Data
    func loadPosts() {
        var completion: GetPostsCompletion = {[weak self](posts: [AnyObject]!) -> Void in
            if (self != nil) {
                if let p = posts as? [HNPost] {
                    var s = self!
                    s.currentPosts = p
                    s.postsTableView.reloadData()
                }
            }
        }
        HNManager.sharedManager().loadPostsWithFilter(currentPostType, completion:completion)
    }
    
    func loadPosts(username: String) {
        var completion: GetPostsCompletion = {[weak self](posts: [AnyObject]!) -> Void in
            if (self != nil) {
                if let p = posts as? [HNPost] {
                    var s = self!
                    s.currentPosts = p
                    s.postsTableView.reloadData()
                }
            }
        }
        HNManager.sharedManager().fetchSubmissionsForUser(username, completion: completion)
    }
    
    func loadAdditionalPosts() {
        var completion: GetPostsCompletion = {[weak self](posts: [AnyObject]!) -> Void in
            if (self != nil) {
                if let p = posts as? [HNPost] {
                    var s = self!
                    s.isLoadingPosts = false
                    s.currentPosts = s.currentPosts + p
                    s.postsTableView.reloadData()
                }
            }
        }
        HNManager.sharedManager().loadPostsWithUrlAddition(HNManager.sharedManager().postUrlAddition, completion: completion)
    }
    
    
    // Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPosts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: HNPostsCollectionCell = tableView.dequeueReusableCellWithIdentifier(HNPostsCollectionCellIdentifier, forIndexPath: indexPath) as HNPostsCollectionCell
        cell.setContentWithPost(currentPosts[indexPath.row], indexPath: indexPath, delegate: self)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var post = currentPosts[indexPath.row]
        if (NSString(string: post.UrlString).contains("item?id=")) {
            didSelectComments(indexPath.row)
        }
        else {
            HNNavigationBrain.navigateToWebViewController(post)
            HNManager.sharedManager().setMarkAsReadForPost(post)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    // Scroll View Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var indexes = postsTableView.indexPathsForVisibleRows()
        if (indexes != nil && indexes?.count > 0) {
            let i = indexes![indexes!.count - 1] as NSIndexPath
            if (i.row == currentPosts.count - 3 && !isLoadingPosts) {
                isLoadingPosts = true
                loadAdditionalPosts()
            }
        }
    }
    
    
    // Posts Cell Delegate
    func didSelectComments(index: Int) {
        let post = currentPosts[index]
        HNNavigationBrain.navigateToComments(post)
    }
    
    
    // HNGridMenuView Delegate
    override func didSelectGridMenuOption(name: String, idx: Int, type: HNMenuType) {
        if (type == HNMenuType.AllPosts) {
            if (name == "New Post") {
                HNNavigationBrain.navigateToNewPostSubmission(navigationController!)
            }
            else if (name == "Share App") {
                BGUtils.shareObject(nil, fromViewController: self)
            }
        }
    }
    
    override func didToggleActionsButton() {
        var options = HNManager.sharedManager().SessionUser != nil ? ["New Post","Share App"] : ["Share App"]
        HNGridMenuView.showMenuViewWithType(menuType, vc: self, _delegate: self, options: options)
    }
}
