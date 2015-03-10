//
//  RNGridMenuView.swift
//  HN
//
//  Created by Ben Gordon on 10/4/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

enum HNMenuType: Int {
    case AllPosts, AllComments, OneComment, Link
}

protocol HNGridMenuViewDelegate {
    func didSelectGridMenuOption(name: String, idx: Int, type: HNMenuType)
}

class HNGridMenuView: RNGridMenu, RNGridMenuDelegate {
    var currentType: HNMenuType = .AllPosts
    var menuOptions: [String]? = nil
    var del: HNGridMenuViewDelegate? = nil
    var viewController: UIViewController? = nil
    
    class func showMenuViewWithType(type: HNMenuType, vc: UIViewController, _delegate: HNGridMenuViewDelegate, options: [AnyObject]?) {
        var m = HNGridMenuView(titles: options != nil ? options : menuOptionsForType(type))
        m.highlightColor = HNThemeManager.Theme.CommentLinkColor
        m.itemFont = UIFont.systemFontOfSize(15.0)
        m.itemSize = CGSizeMake(200, 50)
        m.cornerRadius = 3.0
        m.del = _delegate
        m.currentType = type
        m.delegate = m
        m.viewController = vc
        if (m.items.count > 0) {
            m.showInViewController(vc, center: vc.view.center)
        }
    }
    
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        del?.didSelectGridMenuOption(item.title, idx: itemIndex, type: currentType)
    }
    
    class func bounceGridMenuIfOnScreen() {
        if let menu = RNGridMenu.visibleGridMenu() as? HNGridMenuView {
            let v = menu.viewController?.view
            let c = v!.center
            menu.showInViewController(menu.viewController, center: c)
        }
    }
    
    class func menuOptionsForType(type: HNMenuType) -> [AnyObject]? {
        switch (type) {
        case HNMenuType.AllPosts:
            return ["New Post","Share App"]
        case HNMenuType.AllComments:
            return ["Link","Reply","Share"]
        case HNMenuType.Link:
            return ["Comments","Share"]
        case HNMenuType.OneComment:
            return ["Reply","Share","Upvote","Downvote"]
        default:
            return nil
        }
    }
}
