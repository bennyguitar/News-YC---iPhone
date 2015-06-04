//
//  ViewController.swift
//  HN
//
//  Created by Ben Gordon on 9/8/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNViewController: BMYScrollableNavigationBarViewController, HNGridMenuViewDelegate {
    // Properties
    var hamburgerButton: FRDLivelyButton? = nil
    var actionsButton: FRDLivelyButton? = nil
    var shouldShowActionsButton = true
    var isShowingActionsView = false
    var menuType: HNMenuType = .AllPosts
    
    // Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        resetUI()
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNavigationNotification:", name: HNNavigationBrainShouldNavigateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveThemeChangeNotification:", name: HNThemeChangeNotificationKey, object: nil)
    }
    
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: HNNavigationBrainShouldNavigateNotification, object: nil)
    }


    // UI
    func buildNavBar() {
        // Nav Bar and Colors
        navigationController?.navigationBar.opaque = true
        navigationController?.navigationBar.barTintColor = HNThemeManager.Theme.PrimaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:HNThemeManager.Theme.PrimaryColor]
        navigationController?.navigationBar.tintColor = HNThemeManager.Theme.NavLinkColor
        
        // Hamburger Button
        hamburgerButton = FRDLivelyButton(frame: CGRectMake(0,0,36,28))
        hamburgerButton?.setStyle(kFRDLivelyButtonStyleHamburger, animated: true)
        hamburgerButton?.options = [kFRDLivelyButtonLineWidth: 1.5, kFRDLivelyButtonColor: HNThemeManager.Theme.NavLinkColor, kFRDLivelyButtonHighlightedColor: HNThemeManager.Theme.NavLinkColor.darken(0.08)]
        hamburgerButton?.addTarget(self, action: "didToggleNavigationMenu", forControlEvents: UIControlEvents.TouchUpInside)
        var barButtonItem = UIBarButtonItem(customView: hamburgerButton!)
        
        // Actions Button
        if (shouldShowActionsButton) {
            actionsButton = FRDLivelyButton(frame: CGRectMake(0,0,36,28))
            actionsButton?.setStyle((isShowingActionsView ? kFRDLivelyButtonStyleClose : kFRDLivelyButtonStyleCaretDown), animated: true)
            actionsButton?.options = [kFRDLivelyButtonLineWidth: 1.5, kFRDLivelyButtonColor: HNThemeManager.Theme.NavLinkColor, kFRDLivelyButtonHighlightedColor: HNThemeManager.Theme.NavLinkColor.darken(0.08)]
            actionsButton?.addTarget(self, action: "didToggleActionsButton", forControlEvents: UIControlEvents.TouchUpInside)
            var barButtonItem2 = UIBarButtonItem(customView: actionsButton!)
            navigationItem.rightBarButtonItems = [barButtonItem, barButtonItem2]
        }
        else {
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    func resetUI() {
        buildNavBar()
        HNGridMenuView.bounceGridMenuIfOnScreen()
    }
    
    func setActionsButtonActive(active: Bool) {
        shouldShowActionsButton = active
        buildNavBar()
    }
    
    // Notifications
    func didReceiveNavigationNotification(note: NSNotification?) {
        if (navigationController?.viewControllers.last as! HNViewController == self) {
            if (note != nil && note!.userInfo != nil) {
                let vc = note!.userInfo![HNNavigationBrainVCKey] as! HNViewController
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func didReceiveThemeChangeNotification(note: NSNotification?) {
        resetUI()
    }
    
    // IBActions
    func didToggleNavigationMenu() {
        mm_drawerController.toggleDrawerSide(MMDrawerSide.Right, animated: true, completion: nil)
    }
    
    func didToggleActionsButton() {
        //HNGridMenuView.showMenuViewWithType(menuType, vc: self, _delegate: self, options: nil)
    }
    
    // HNGridMenuView Delegate
    func didSelectGridMenuOption(name: String, idx: Int, type: HNMenuType) {
        //
    }
}

