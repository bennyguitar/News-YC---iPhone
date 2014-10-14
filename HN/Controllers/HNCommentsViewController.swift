//
//  HNCommentsViewController.swift
//  HN
//
//  Created by Ben Gordon on 9/17/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNCommentsViewController: HNViewController, UITableViewDelegate, UITableViewDataSource, HNCommentsCellDelegate {
    @IBOutlet weak var commentsTableView: UITableView!
    var currentPost: HNPost? = nil
    var allComments: [HNComment]? = []
    var topLevelHiddenIndexPaths: NSMutableIndexSet? = NSMutableIndexSet()
    var hiddenCommentMap: [String:Int] = Dictionary()
    var visibleIndexPath: NSIndexPath? = nil
    var didSelectIndex: Int? = 0
    var refreshControl: UIRefreshControl? = nil
    
    // MARK: - Init
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, post: HNPost?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        currentPost = post!
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        buildUI()
        resetUI()
        menuType = .AllComments
        
        // Data
        loadComments()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        //bindNavigationBarToScrollView(commentsTableView)
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        commentsTableView.reloadData()
        if (visibleIndexPath != nil) {
            commentsTableView.scrollToRowAtIndexPath(visibleIndexPath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        visibleIndexPath = commentsTableView.indexPathsForVisibleRows()!.first as? NSIndexPath
    }

    
    // MARK: - UI
    func buildUI() {
        // Table View
        commentsTableView.registerNib(UINib(nibName: BGUtils.className(HNCommentCell), bundle: nil), forCellReuseIdentifier: HNPostsCollectionCellIdentifier)
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 72.0
        commentsTableView.separatorInset = UIEdgeInsetsZero
        if (commentsTableView.respondsToSelector("layoutMargins")) {
            commentsTableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "loadComments", forControlEvents: .ValueChanged)
        commentsTableView.addSubview(refreshControl!)
    }
    
    override func resetUI() {
        super.resetUI()
        
        // Table
        commentsTableView.separatorColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.CellSeparator)
        commentsTableView.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        commentsTableView.reloadData()
        
        // Refresh
        refreshControl?.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        refreshControl?.tintColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.MainFont)
    }
    
    
    // MARK: - Load Data
    func loadComments() {
        refreshControl?.beginRefreshing()
        if (currentPost != nil) {
            HNManager.sharedManager().loadCommentsFromPost(currentPost, completion: {[weak self](comments) -> Void in
                if (comments != nil && self != nil) {
                    var s = self!
                    s.refreshControl?.endRefreshing()
                    s.allComments = comments as? [HNComment]
                    s.commentsTableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allComments!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create Cell
        var cell: HNCommentCell = tableView.dequeueReusableCellWithIdentifier(HNPostsCollectionCellIdentifier, forIndexPath: indexPath) as HNCommentCell
        
        // Return it
        cell.setContentWithComment(allComments![indexPath.row], indexPath: indexPath, delegate: self, visibility: HNCommentCellVisibility.Visible)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //singleCommentMenuView?.launchInView(view, launch: true)
        didSelectIndex = indexPath.row
        var options = HNManager.sharedManager().SessionUser != nil ? ["Reply", "Share", "Upvote", "Downvote"] : ["Share"]
        HNGridMenuView.showMenuViewWithType(.OneComment, vc: self, _delegate: self, options: options)
    }
    
    
    // MARK: - Comments Delegate
    func didSelectHideNested(index: Int, level: Int) {
        /*
        // Add or Remove from Top Level Hidden Indexes
        var isHiding = true
        if (topLevelHiddenIndexPaths!.containsIndex(index)) {
            isHiding = false
            topLevelHiddenIndexPaths!.removeIndex(index)
        }
        else {
            topLevelHiddenIndexPaths!.addIndex(index)
        }
        
        // Add or Remove from all hidden comments
        for (var i = index + 1; i < allComments!.count - index; i++) {
            // If level is the same or less, get out of this loop
            let comment = allComments![i]
            if (Int(comment.Level) <= level) {
                hiddenCommentMap[comment.CommentId] = nil
                break;
            }
            else {
                hiddenCommentMap[comment.CommentId] = isHiding ? 1 : nil
            }
            
            // Set Comment Map up
            //hiddenCommentMap[comment.CommentId] = isHiding ? 1 : nil
        }
        
        // Reload
        commentsTableView.reloadData()
        */
    }
    
    // Grid Menu
    override func didSelectGridMenuOption(name: String, idx: Int, type: HNMenuType) {
        if (type == HNMenuType.AllComments) {
            if (name == "Link") {
                HNNavigationBrain.navigateToWebViewController(currentPost!)
            }
            else if (name == "Reply") {
                HNNavigationBrain.navigateToReply(currentPost, navController: navigationController!)
            }
            else if (name == "Share") {
                BGUtils.shareObject("https://news.ycombinator.com/item?id=\(currentPost!.PostId)", fromViewController: self)
            }
            else if (name == "Upvote Post") {
                BGUtils.vote(true, object: currentPost!)
            }
        }
        else if (type == HNMenuType.OneComment) {
            let comment = allComments![didSelectIndex!] as HNComment
            if (name == "Share") {
                BGUtils.shareObject(comment, fromViewController: self)
            }
            else if (name == "Upvote") {
                BGUtils.vote(true, object: comment)
            }
            else if (name == "Downvote") {
                BGUtils.vote(false, object: comment)
            }
            else if (name == "Reply") {
                HNNavigationBrain.navigateToReply(comment, navController: navigationController!)
            }
        }
    }
    
    override func didToggleActionsButton() {
        var options = HNManager.sharedManager().SessionUser != nil ? ["Link","Reply", "Share","Upvote Post"] : ["Link", "Share"]
        HNGridMenuView.showMenuViewWithType(menuType, vc: self, _delegate: self, options: options)
    }
}
