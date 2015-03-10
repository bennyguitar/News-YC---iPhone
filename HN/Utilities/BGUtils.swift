//
//  BGUtils.swift
//  HN
//
//  Created by Ben Gordon on 9/8/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class BGUtils: NSObject {
    class func className(classType:AnyClass) -> String {
        let classString = NSStringFromClass(classType.self)
        return classString.componentsSeparatedByString(".")[1]
    }
    
    class func shareObject(obj: AnyObject?, fromViewController vc: HNViewController) {
        var urlString: String? = "https://itunes.apple.com/us/app/news-yc/id592893508?mt=8"
        if let comment = obj as? HNComment {
            urlString = "https://news.ycombinator.com/item?id=\(comment.CommentId)"
        }
        else if let u = obj as? String {
            urlString = u
        }
        
        if let url = NSURL(string: urlString!) {
            var activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            vc.navigationController?.presentViewController(activityController, animated: true, completion: nil)
        }
    }
    
    class func vote(up: Bool, object: AnyObject) {
        HNManager.sharedManager().voteOnPostOrComment(object, direction: up ? .Up : .Down) { (success) -> Void in
            if (success) {
                self.showSuccessMessage("Voting Success!")
                return
            }
            self.showFailureMessate("Voting Failed!")
        }
    }
    
    class func showSuccessMessage(msg: String) {
        var m = MTStatusBarOverlay.sharedInstance()
        m.animation = MTStatusBarOverlayAnimationFallDown
        m.postFinishMessage(msg, duration: 2.0, animated: true)
    }
    
    class func showFailureMessate(msg: String) {
        var m = MTStatusBarOverlay.sharedInstance()
        m.animation = MTStatusBarOverlayAnimationFallDown
        m.postErrorMessage(msg, duration: 2.0, animated: true)
    }
    
    class func themedRefreshControl(target: AnyObject!, selector: Selector) -> UIRefreshControl {
        var r = UIRefreshControl()
        r.backgroundColor = HNThemeManager.Theme.BackgroundColor
        r.tintColor = HNThemeManager.Theme.Bar
        r.addTarget(target, action: selector, forControlEvents: .ValueChanged)
        return r
    }
}
