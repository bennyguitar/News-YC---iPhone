//
//  HNWebViewController.swift
//  HN
//
//  Created by Ben Gordon on 9/19/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNWebViewController: HNViewController, UIWebViewDelegate {
    @IBOutlet weak var webActionsBar: UIView!
    @IBOutlet weak var linkWebView: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    var currentPost: HNPost? = nil
    var url: NSURL? = nil

    // MARK: - Init
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, post: HNPost?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        currentPost = post
        menuType = .Link
        url = NSURL(string: post!.UrlString)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, urlString: NSString?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        url = NSURL(string: urlString! as String)
        menuType = .Link
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        buildUI()
        
        // Load URL
        loadUrl()
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserverForName(HNReadabilityDidChangeNotification, object: nil, queue: nil) { [weak self](note) -> Void in
            if (self != nil) {
                self!.loadUrl()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    func buildUI() {
        buildWebActionsUI()
        setWebActionsUI()
    }
    
    override func resetUI() {
        super.resetUI()
        buildUI()
    }
    
    func buildWebActionsUI() {
        webActionsBar.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.PrimaryColor)
        backButton.setImage(UIImage(named: "web_back-01")!.imageWithNewColor(HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.NavLinkColor)), forState: UIControlState.Normal)
        forwardButton.setImage(UIImage(named: "web_forward-01")!.imageWithNewColor(HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.NavLinkColor)), forState: UIControlState.Normal)
        refreshButton.setImage(UIImage(named: "web_refresh-01")!.imageWithNewColor(HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.NavLinkColor)), forState: UIControlState.Normal)
    }
    
    func setWebActionsUI() {
        backButton.enabled = linkWebView.canGoBack
        backButton.alpha = linkWebView.canGoBack ? 1.0 : 0.35
        forwardButton.enabled = linkWebView.canGoForward
        forwardButton.alpha = linkWebView.canGoForward ? 1.0 : 0.35
    }
    
    
    // Web View Delegate
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        setWebActionsUI()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        setWebActionsUI()
    }
    
    // Web Actions
    @IBAction func didSelectBack(sender: AnyObject) {
        linkWebView.goBack()
    }
    
    @IBAction func didSelectForward(sender: AnyObject) {
        linkWebView.goForward()
    }
    
    @IBAction func didSelectRefresh(sender: AnyObject) {
        linkWebView.reload()
    }
    
    
    // HNGridMenuView Delegate
    override func didSelectGridMenuOption(name: String, idx: Int, type: HNMenuType) {
        if (type == HNMenuType.Link) {
            if (name == "Comments") {
                HNNavigationBrain.navigateToComments(currentPost!)
            }
            else if (name == "Share") {
                BGUtils.shareObject(url?.absoluteString, fromViewController: self)
            }
            else if (name == "Upvote Post") {
                BGUtils.vote(true, object: currentPost!)
            }
        }
    }
    
    override func didToggleActionsButton() {
        var options = currentPost != nil ? ["Comments", "Share","Upvote Post"] : ["Share"]
        HNGridMenuView.showMenuViewWithType(menuType, vc: self, _delegate: self, options: options)
    }
    
    func loadUrl() {
        if (url != nil) {
            var u = HNTheme.currentTheme().readabilityIsActive() ? NSURL(string: "http://www.readability.com/m?url=\(url!.absoluteString!)") : url!
            linkWebView.loadRequest(NSURLRequest(URL: u!))
        }
    }
}
