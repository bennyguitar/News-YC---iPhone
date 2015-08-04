//
//  HNNavigationViewController.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit
let HNDidLoginOrOutNotification = "DidLoginOrOut"
enum HNNavCellType: Int {
    case Login, Profile, Theme, Settings, Filter, Credits
}

class HNNavigationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTableView: UITableView!
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        buildTable()
        buildUI()
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveThemeChangeNotification:", name: HNThemeChangeNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLoginLogoutNotification:", name: HNDidLoginOrOutNotification, object: nil)
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        dispatch_after(1, dispatch_get_main_queue(), {
            self.hideKeyboard()
        })
    }
    
    func hideKeyboard() {
        if (mm_drawerController.visibleRightDrawerWidth == 0) {
            view.endEditing(true)
            navigationTableView.endEditing(true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationTableView.setContentOffset(CGPointMake(navigationTableView.contentOffset.x, navigationTableView.contentOffset.y - 1), animated: true)
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - UI
    func buildUI() {
        if (count(HNThemeManager.Theme.Image) > 0) {
            backgroundImageView.image = UIImage(named: HNThemeManager.Theme.Image as String)!
        }
        //backgroundImageView.image = HNTheme.currentTheme().navigationBackgroundImage()
    }
    
    func buildTable() {
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavFilterTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavFilterTableViewCellIdentifier)
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavCreditsTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavCreditsTableViewCellIdentifier)
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavThemeTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavThemeTableViewCellIdentifier)
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavSettingsTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavSettingsTableViewCellIdentifier)
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavLoginTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavLoginTableViewCellIdentifier)
        navigationTableView.registerNib(UINib(nibName: BGUtils.className(HNNavProfileTableViewCell.self), bundle: nil), forCellReuseIdentifier: HNNavProfileTableViewCellIdentifier)
        navigationTableView.estimatedRowHeight = 105
        navigationTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // Navigation Elements
    func currentNavigationElements() -> [HNNavCellType] {
        return HNManager.sharedManager().SessionUser != nil ? [HNNavCellType.Profile, HNNavCellType.Filter, HNNavCellType.Theme, HNNavCellType.Settings, HNNavCellType.Credits] : [HNNavCellType.Login, HNNavCellType.Filter, HNNavCellType.Theme, HNNavCellType.Settings, HNNavCellType.Credits]
    }
    
    func cellIdentifierForNavigationType(type: HNNavCellType) -> String {
        switch (type) {
        case .Login:
            return HNNavLoginTableViewCellIdentifier
        case .Profile:
            return HNNavProfileTableViewCellIdentifier
        case .Theme:
            return HNNavThemeTableViewCellIdentifier
        case .Settings:
            return HNNavSettingsTableViewCellIdentifier
        case .Credits:
            return HNNavCreditsTableViewCellIdentifier
        case .Filter:
            return HNNavFilterTableViewCellIdentifier
        default:
            return HNNavFilterTableViewCellIdentifier
        }
    }
    
    func cellForNavigationType(type: HNNavCellType) -> UITableViewCell {
        return navigationTableView.dequeueReusableCellWithIdentifier(cellIdentifierForNavigationType(type)) as! UITableViewCell
    }
    
    func textForNavigationType(type: HNNavCellType) -> String {
        switch (type) {
        case .Login:
            return "Login"
        case .Profile:
            return "Profile"
        case .Theme:
            return "Theme"
        case .Settings:
            return "Settings"
        case .Credits:
            return "Credits"
        case .Filter:
            return "Filter Posts"
        default:
            return ""
        }
    }
    
    // Table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return currentNavigationElements().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellForNavigationType(currentNavigationElements()[indexPath.section])
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HNNavTableHeader.height()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HNNavTableHeader.headerWithText(textForNavigationType(currentNavigationElements()[section]))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    // ScrollView
    func scrollViewDidScroll(scrollView: UIScrollView) {
        navigationTableView.endEditing(true)
    }
    
    // Notification
    func didReceiveThemeChangeNotification(note: NSNotification?) {
        buildUI()
    }
    
    // Login/Out
    func didReceiveLoginLogoutNotification(note: NSNotification?) {
        navigationTableView.reloadData()
    }
}
