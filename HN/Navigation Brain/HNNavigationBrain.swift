//
//  HNNavigationBrain.swift
//  HN
//
//  Created by Ben Gordon on 9/21/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavigationBrainShouldNavigateNotification = "HNNavigationBrainShouldNavigateNotification"
let HNNavigationBrainVCKey = "HNNavigationBrainVCKey"

class HNNavigationBrain {
    // Main Nav
    private class func navigateToViewController(vc: UIViewController!) {
        if (vc != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName(HNNavigationBrainShouldNavigateNotification, object: nil, userInfo: [HNNavigationBrainVCKey:vc])
        }
    }
    
    // External Navigation Methods
    class func navigateToWebViewController(urlString: String) {
        let vc = HNWebViewController(nibName: BGUtils.className(HNWebViewController), bundle: nil, urlString: urlString)
        navigateToViewController(vc)
    }
    
    class func navigateToWebViewController(post: HNPost) {
        let vc = HNWebViewController(nibName: BGUtils.className(HNWebViewController), bundle: nil, post: post)
        navigateToViewController(vc)
    }
    
    class func navigateToComments(post: HNPost) {
        let vc = HNCommentsViewController(nibName: BGUtils.className(HNCommentsViewController), bundle: nil, post: post)
        navigateToViewController(vc)
    }
    
    class func navigateToPosts(type: PostFilterType) {
        let vc = HNPostsViewController(nibName: BGUtils.className(HNPostsViewController), bundle: nil, postType: type)
        navigateToViewController(vc)
    }
    
    class func navigateToPosts(username: String) {
        let vc = HNPostsViewController(nibName: BGUtils.className(HNPostsViewController), bundle: nil, username: username)
        navigateToViewController(vc)
    }
    
    class func navigateToNewPostSubmission(navController: UINavigationController) {
        let vc = HNSubmissionViewController(hnObject: nil)
        navController.pushViewController(vc, animated: true)
    }
    
    class func navigateToReply(replyObject: AnyObject?, navController: UINavigationController) {
        let vc = HNSubmissionViewController(hnObject: replyObject)
        var submissionType = HNSubmissionType.NewPost
        if (replyObject != nil) {
            if (replyObject!.isKindOfClass(HNPost.self)) {
                submissionType = .PostReply
            }
            else if (replyObject!.isKindOfClass(HNComment.self)) {
                submissionType = .CommentReply
            }
        }
        vc.currentHNObject = replyObject
        vc.currentSubmissionType = submissionType
        navController.pushViewController(vc, animated: true)
    }
}
