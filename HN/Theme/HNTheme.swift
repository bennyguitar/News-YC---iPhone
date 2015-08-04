//
//  HNTheme.swift
//  HN
//
//  Created by Ben Gordon on 9/9/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

// Properties
let HNOrangeColor = UIColor(red:1.0, green:78/255.0, blue:0, alpha:1.0)
let HNCommentBubbleLight = UIImage(named: "commentbubble-01.png")

let NameKey = "Name"
let BackgroundColorKey = "BackgroundColor"
let PrimaryColorKey = "PrimaryColor"
let BarKey = "Bar"
let MainFontKey = "MainFont"
let SubFontKey = "SubFont"
let JobsBackgroundKey = "JobsBackgorund"
let JobsBarKey = "JobsBar"
let ShowHNBackgroundKey = "ShowHNBackground"
let ShowHNBarKey = "ShowHNBar"
let ShowHNCommentBubbleKey = "ShowHNCommentBubble"
let CellSeparatorKey = "CellSeparator"
let NavLinkColorKey = "NavLinkColor"
let CommentLinkColorKey = "CommentLinkColor"
let CommentBubbleKey = "CommentBubble"
let ImageKey = "Image"
let ImageUrlKey = "ImageUrl"
let ProKey = "Pro"

// Class
class HNTheme: NSObject {
    // Properties
    var BackgroundColor: UIColor = UIColor.clearColor()
    var PrimaryColor: UIColor = UIColor.clearColor()
    var Bar: UIColor = UIColor.clearColor()
    var MainFont: UIColor = UIColor.clearColor()
    var SubFont: UIColor = UIColor.clearColor()
    var CommentBubble: UIColor = UIColor.clearColor()
    var JobsBackground: UIColor = UIColor.clearColor()
    var JobsBar: UIColor = UIColor.clearColor()
    var ShowHNBackground: UIColor = UIColor.clearColor()
    var ShowHNBar: UIColor = UIColor.clearColor()
    var ShowHNCommentBubble: UIColor = UIColor.clearColor()
    var CellSeparator: UIColor = UIColor.clearColor()
    var NavLinkColor: UIColor = UIColor.clearColor()
    var CommentLinkColor: UIColor = UIColor.clearColor()
    var CommentBubbleImage = UIImage()
    var ShowHNCommentBubbleImage = UIImage()
    var Image: String = ""
    var ImageUrl: String = ""
    var Name: String = ""
    var Pro: Bool = false
    var Index: Int = 0
    
    // Enums
    enum ThemeType: Int {
        case Day, Night, Minima, SpaceOne
    }
    
    enum ThemeUIElement: Int {
        case BackgroundColor, PrimaryColor, Bar, MainFont, SubFont, CommentBubble, JobsBackground, JobsBar, ShowHNBackground, ShowHNBar, CellSeparator, NavLinkColor, CommentLinkColor
    }
    
    class func lintedDictionary(json: NSString) -> NSDictionary? {
        if let dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
            if (dict[BackgroundColorKey] == nil) {
                return nil;
            }
            if (dict[PrimaryColorKey] == nil) {
                return nil;
            }
            if (dict[BarKey] == nil) {
                return nil;
            }
            if (dict[MainFontKey] == nil) {
                return nil;
            }
            if (dict[SubFontKey] == nil) {
                return nil;
            }
            if (dict[JobsBackgroundKey] == nil) {
                return nil;
            }
            if (dict[JobsBarKey] == nil) {
                return nil;
            }
            if (dict[ShowHNBackgroundKey] == nil) {
                return nil;
            }
            if (dict[ShowHNBarKey] == nil) {
                return nil;
            }
            if (dict[CellSeparatorKey] == nil) {
                return nil;
            }
            if (dict[NavLinkColorKey] == nil) {
                return nil;
            }
            if (dict[CommentLinkColorKey] == nil) {
                return nil;
            }
            
            return dict;
        }
        
        return nil;
    }
    
    // MARK: - Init
    init(json: NSString) {
        if let dict = HNTheme.lintedDictionary(json) {
            BackgroundColor = UIColor(fromHexString: dict[BackgroundColorKey] as! String)
            PrimaryColor = UIColor(fromHexString: dict[PrimaryColorKey] as! String)
            Bar = UIColor(fromHexString: dict[BarKey] as! String)
            MainFont = UIColor(fromHexString: dict[MainFontKey] as! String)
            SubFont = UIColor(fromHexString: dict[SubFontKey] as! String)
            JobsBackground = UIColor(fromHexString: dict[JobsBackgroundKey] as! String)
            JobsBar = UIColor(fromHexString: dict[JobsBarKey] as! String)
            ShowHNBackground = UIColor(fromHexString: dict[ShowHNBackgroundKey] as! String)
            ShowHNBar = UIColor(fromHexString: dict[ShowHNBarKey] as! String)
            CellSeparator = UIColor(fromHexString: dict[CellSeparatorKey] as! String)
            NavLinkColor = UIColor(fromHexString: dict[NavLinkColorKey] as! String)
            CommentLinkColor = UIColor(fromHexString: dict[CommentLinkColorKey] as! String)
            
            if (dict[CommentBubbleKey] != nil) {
                CommentBubble = UIColor(fromHexString: dict[CommentBubbleKey] as! String)
                CommentBubbleImage = HNCommentBubbleLight!.imageWithNewColor(CommentBubble);
            }
            if (dict[ShowHNCommentBubbleKey] != nil) {
                ShowHNCommentBubble = UIColor(fromHexString: dict[ShowHNCommentBubbleKey] as! String)
                ShowHNCommentBubbleImage = HNCommentBubbleLight!.imageWithNewColor(ShowHNCommentBubble);
            }
            if (dict[ImageKey] != nil) {
                Image = dict[ImageKey] as! String
            }
            if (dict[ImageUrlKey] != nil) {
                ImageUrl = dict[ImageUrlKey] as! String
            }
            if (dict[ProKey] != nil) {
                Pro = true
            }
        }
    }
    
    override init() {
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNReadabilityDefaultsKey) == nil) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: HNReadabilityDefaultsKey)
        }
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNMarkAsReadDefaultsKey) == nil) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: HNMarkAsReadDefaultsKey)
        }
    }
}
