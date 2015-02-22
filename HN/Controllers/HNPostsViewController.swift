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
    var shouldLoadNewPosts = true
    var refreshControl: UIRefreshControl? = nil
    var nextPageUrlAddition: String? = nil

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadPosts"), name: kHNShouldReloadDataFromConfiguration, object: nil);
        
        // Load Data
        loadPosts()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        //bindNavigationBarToScrollView(postsTableView)
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
        if (postsTableView.respondsToSelector(Selector("layoutMargins"))) {
            postsTableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "didPullRefreshControl", forControlEvents: .ValueChanged)
        postsTableView.addSubview(refreshControl!)
    }
    
    override func resetUI() {
        super.resetUI()
        
        // Table
        postsTableView.separatorColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.CellSeparator)
        postsTableView.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        postsTableView.reloadData()
        
        // Refresh Control
        refreshControl?.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        refreshControl?.tintColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.MainFont)
    }

    
    // Load Data
    func loadPosts() {
        // Return if we're already loading
        if (isLoadingPosts) {
            return
        }
        
        refreshControl?.beginRefreshing()
        isLoadingPosts = true
        
        // Build the completion closure
        var completion: GetPostsCompletion = {[weak self](posts: [AnyObject]!, urlAddition: String!) -> Void in
            if let s = self {
                s.refreshControl?.endRefreshing()
                if let p = posts as? [HNPost] {
                    s.isLoadingPosts = false
                    s.currentPosts = (s.shouldLoadNewPosts ? p : s.currentPosts + p)
                    s.nextPageUrlAddition = urlAddition!
                    s.shouldLoadNewPosts = false
                    s.postsTableView.reloadData()
                }
            }
        }
        
        if (shouldLoadNewPosts && user == nil) {
            // Refresh Pulled
            HNManager.sharedManager().loadPostsWithFilter(currentPostType, completion:completion)
            return
        }
        
        // Url Addition && User
        if (nextPageUrlAddition != nil && NSString(string: nextPageUrlAddition!).length > 0 && user != nil) {
            HNManager.sharedManager().fetchSubmissionsForUser(user!, urlAddition: nextPageUrlAddition!, completion: completion)
            return
        }
        
        // Url Addition
        if (nextPageUrlAddition != nil && NSString(string: nextPageUrlAddition!).length > 0) {
            HNManager.sharedManager().loadPostsWithUrlAddition(nextPageUrlAddition!, completion: completion)
            return
        }
        
        // Username
        if (user != nil && currentPosts.count == 0){
            HNManager.sharedManager().fetchSubmissionsForUser(user, urlAddition: nil, completion: completion)
            return
        }
        
        refreshControl?.endRefreshing()
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
                loadPosts()
            }
        }
    }
    
    
    // Refresh Control
    func didPullRefreshControl() {
        isLoadingPosts = false
        shouldLoadNewPosts = true
        loadPosts()
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
