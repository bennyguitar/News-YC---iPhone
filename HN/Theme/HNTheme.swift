//
//  HNTheme.swift
//  HN
//
//  Created by Ben Gordon on 9/9/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

// Properties
var currTheme: HNTheme? = nil
let HNThemeDefaultsKey = "HNThemeDefaultsKey"
let HNReadabilityDefaultsKey = "HNReadabilityDefaultsKey"
let HNMarkAsReadDefaultsKey = "HNMarkAsReadDefaultsKey"
let HNThemeChangeNotificationKey = "HNThemeChangeNotificationKey"
let HNReadabilityDidChangeNotification = "HNReadabilityDidChangeNotification"
let HNMarkAsReadDidChangeNotification = "HNMarkAsReadDidChangeNotification"
let HNOrangeColor = UIColor(red:1.0, green:78/255.0, blue:0, alpha:1.0)
let HNCommentBubbleDark = UIImage(named: "commentbubbleDark.png")
let HNCommentBubbleLight = UIImage(named: "commentbubble-01.png")

// Class
class HNTheme: NSObject {
    // Enums
    enum ThemeType: Int {
        case Day, Night, Minima, SpaceOne
    }
    
    enum ThemeUIElement: Int {
        case BackgroundColor, PrimaryColor, Bar, MainFont, SubFont, CommentBubble, JobsBackground, JobsBar, ShowHNBackground, ShowHNBar, CellSeparator, NavLinkColor, CommentLinkColor
    }
    
    // Properties
    var themeType = ThemeType.Day
    
    // Singleton
    class func currentTheme() -> HNTheme {
        if (currTheme == nil) {
            currTheme = HNTheme()
            currTheme?.setUp()
        }
        return currTheme!
    }
    
    // Init
    override init() {
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNReadabilityDefaultsKey) == nil) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: HNReadabilityDefaultsKey)
        }
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNMarkAsReadDefaultsKey) == nil) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: HNMarkAsReadDefaultsKey)
        }
    }
    
    // Set Up
    func setUp() {
        // Set Theme from User Defaults
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNThemeDefaultsKey) != nil) {
            let k : AnyObject! = NSUserDefaults.standardUserDefaults().valueForKey(HNThemeDefaultsKey)
            themeType = ThemeType.fromRaw(k.integerValue)!
            return
        }
        
        themeType = .Day
    }
    
    // Image
    func imageForCommentBubble() -> UIImage {
        switch (themeType) {
        case .Day:
            return HNCommentBubbleDark
        case .Night:
            return HNCommentBubbleLight
        case .SpaceOne:
            return HNCommentBubbleDark
        case .Minima:
            return UIImage()
        default:
            return HNCommentBubbleLight
        }
    }
    
    // Color
    func colorForUIElement(elem: ThemeUIElement) -> UIColor {
        // Day
        if (themeType == ThemeType.Day) {
            switch (elem) {
            case ThemeUIElement.BackgroundColor:
                return UIColor(white:0.85, alpha:1.0)
            case ThemeUIElement.PrimaryColor:
                return HNOrangeColor
            case ThemeUIElement.Bar:
                return UIColor(white:0.75, alpha:1.0)
            case ThemeUIElement.MainFont:
                return UIColor(white:0.4, alpha:1.0)
            case ThemeUIElement.SubFont:
                return UIColor(white:0.2, alpha:1.0)
            case ThemeUIElement.CommentBubble:
                return UIColor(white:0.75, alpha:1.0)
            case ThemeUIElement.JobsBackground:
                return UIColor(red:170/255.0, green:235/255.0, blue:185/255.0, alpha:1.0)
            case ThemeUIElement.JobsBar:
                return UIColor(red:128/255.0,green:178/255.0,blue:141/255.0, alpha:1.0)
            case ThemeUIElement.ShowHNBackground:
                return UIColor(red:252/255.0,green:163/255.0,blue:131/255.0, alpha:1.0)
            case ThemeUIElement.ShowHNBar:
                return UIColor(red:205/255.0,green:133/255.0,blue:109/255.0, alpha:1.0)
            case ThemeUIElement.CellSeparator:
                return UIColor(white:0.75, alpha:1.0)
            case ThemeUIElement.NavLinkColor:
                return UIColor(white:0.0, alpha:0.55)
            case ThemeUIElement.CommentLinkColor:
                return HNOrangeColor
            default:
                return UIColor.charcoalColor()
            }
        }
        
        // Night
        else if (themeType == ThemeType.Night) {
            switch (elem) {
            case ThemeUIElement.BackgroundColor:
                return UIColor(white:0.15, alpha:1.0)
            case ThemeUIElement.PrimaryColor:
                return HNOrangeColor
            case ThemeUIElement.Bar:
                return UIColor(white:0.22, alpha:1.0)
            case ThemeUIElement.MainFont:
                return UIColor(white:0.92, alpha:1.0)
            case ThemeUIElement.SubFont:
                return UIColor(white:0.85, alpha:1.0)
            case ThemeUIElement.CommentBubble:
                return UIColor(white:0.35, alpha:1.0)
            case ThemeUIElement.JobsBackground:
                return UIColor(red:60/255.0, green:120/255.0, blue:71/255.0, alpha:1.0)
            case ThemeUIElement.JobsBar:
                return UIColor(red:45/255.0, green:90/255.0, blue:55/255.0, alpha:1.0)
            case ThemeUIElement.ShowHNBackground:
                return UIColor(red:149/255.0, green:78/255.0, blue:48/255.0, alpha:1.0)
            case ThemeUIElement.ShowHNBar:
                return UIColor(red:116/255.0, green:61/255.0, blue:39/255.0, alpha:1.0)
            case ThemeUIElement.CellSeparator:
                return UIColor(white:0.25, alpha:1.0)
            case ThemeUIElement.NavLinkColor:
                return UIColor(white:0, alpha:0.55)
            case ThemeUIElement.CommentLinkColor:
                return HNOrangeColor
            default:
                return UIColor.charcoalColor()
            }
        }
        
        // Minima
        else if (themeType == ThemeType.Minima) {
            switch (elem) {
            case ThemeUIElement.BackgroundColor:
                return UIColor(white:0.92, alpha:1.0)
            case ThemeUIElement.PrimaryColor:
                return UIColor(white:0.86, alpha:1.0)
            case ThemeUIElement.Bar:
                return UIColor(white:0.89, alpha:1.0)
            case ThemeUIElement.MainFont:
                return UIColor(white:0.46, alpha:1.0)
            case ThemeUIElement.SubFont:
                return UIColor(white:0.36, alpha:1.0)
            case ThemeUIElement.CommentBubble:
                return UIColor(white:0.86, alpha:1.0)
            case ThemeUIElement.JobsBackground:
                return UIColor(fromHexString:"E5F7D5")
            case ThemeUIElement.JobsBar:
                return UIColor(fromHexString:"DAEDC7")
            case ThemeUIElement.ShowHNBackground:
                return UIColor(fromHexString:"#FED9B4")
            case ThemeUIElement.ShowHNBar:
                return UIColor(fromHexString:"#F3C79E")
            case ThemeUIElement.CellSeparator:
                return UIColor(white:0.78, alpha:1.0)
            case ThemeUIElement.NavLinkColor:
                return UIColor(white:0.55, alpha:1.0)
            case ThemeUIElement.CommentLinkColor:
                return UIColor.charcoalColor()
            default:
                return UIColor.charcoalColor()
            }
        }
        
        // SpaceOne
        else if (themeType == ThemeType.SpaceOne) {
            switch (elem) {
            case ThemeUIElement.BackgroundColor:
                return UIColor(white:0.06, alpha:1.0)
            case ThemeUIElement.PrimaryColor:
                return UIColor(white:0.00, alpha:1.0)
            case ThemeUIElement.Bar:
                return UIColor(white:0.10, alpha:1.0)
            case ThemeUIElement.MainFont:
                return UIColor(white:0.65, alpha:1.0)
            case ThemeUIElement.SubFont:
                return UIColor(white:0.55, alpha:1.0)
            case ThemeUIElement.CommentBubble:
                return UIColor(white:0.12, alpha:1.0)
            case ThemeUIElement.JobsBackground:
                return UIColor(fromHexString:"091408")
            case ThemeUIElement.JobsBar:
                return UIColor(fromHexString:"0D1F0C")
            case ThemeUIElement.ShowHNBackground:
                return UIColor(fromHexString:"#1F120B")
            case ThemeUIElement.ShowHNBar:
                return UIColor(fromHexString:"2E1B11")
            case ThemeUIElement.CellSeparator:
                return UIColor(white:0.10, alpha:1.0)
            case ThemeUIElement.NavLinkColor:
                return UIColor(white:0.35, alpha:1.0)
            case ThemeUIElement.CommentLinkColor:
                return UIColor(fromHexString: "DB9E7D")
            default:
                return UIColor.charcoalColor()
            }
        }
        
        return UIColor.charcoalColor()
    }
    
    // Background Image
    func navigationBackgroundImage() -> UIImage {
        switch (themeType) {
        case ThemeType.Day:
            return UIImage(named: "sanfran.jpg")
        case ThemeType.Night:
            return UIImage(named: "night.jpg")
        case ThemeType.SpaceOne:
            return UIImage(named: "space.jpg")
        case ThemeType.Minima:
            return UIImage(named: "minimal.jpg")
        default:
            return UIImage(named: "sanfran.jpg")
        }
    }
    
    // Change Theme
    func changeTheme(type: HNTheme.ThemeType) {
        themeType = type
        NSUserDefaults.standardUserDefaults().setValue(type.toRaw(), forKey: HNThemeDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(HNThemeChangeNotificationKey, object: nil)
    }
    
    // Readability
    func readabilityIsActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HNReadabilityDefaultsKey)
    }
    
    func readability(on: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(on, forKey: HNReadabilityDefaultsKey)
        NSNotificationCenter.defaultCenter().postNotificationName(HNReadabilityDidChangeNotification, object: nil)
    }
    
    // Mark As Read
    func markAsReadIsActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HNMarkAsReadDefaultsKey)
    }
    
    func markAsRead(on: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(on, forKey: HNMarkAsReadDefaultsKey)
        NSNotificationCenter.defaultCenter().postNotificationName(HNMarkAsReadDidChangeNotification, object: nil)
    }
}
