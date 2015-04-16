//
//  HNThemeManager.swift
//  HN
//
//  Created by Benjamin Gordon on 3/9/15.
//  Copyright (c) 2015 bennyguitar. All rights reserved.
//

import UIKit

let HNThemeDefaultsKey = "HNThemeDefaultsKey"
let HNReadabilityDefaultsKey = "HNReadabilityDefaultsKey"
let HNMarkAsReadDefaultsKey = "HNMarkAsReadDefaultsKey"
let HNThemeChangeNotificationKey = "HNThemeChangeNotificationKey"
let HNReadabilityDidChangeNotification = "HNReadabilityDidChangeNotification"
let HNMarkAsReadDidChangeNotification = "HNMarkAsReadDidChangeNotification"

private var _Instance = HNTheme()
private var _Themes: [HNTheme] = []
private var _FreeThemes: [HNTheme] = []
private var _ProThemes: [HNTheme] = []

class HNThemeManager: NSObject {
    // MARK: - Singleton Instance
    class var Theme: HNTheme {
        return _Instance;
    }
    
    // MARK: - Set Up
    class func setUp() {
        // Create Themes from JSON
        let fileNames = ["day","night","minima","pacific"]
        for var i = 0; i < fileNames.count; i++  {
            let file = fileNames[i]
            let path = NSBundle.mainBundle().pathForResource(file, ofType: "json")
            let json = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
            var theme = HNTheme(json: json!)
            theme.Index = i
            _Themes.append(theme)
            if (theme.Pro) {
                _ProThemes.append(theme)
            }
            else {
                _FreeThemes.append(theme)
            }
        }
        
        // Make Theme
        if (NSUserDefaults.standardUserDefaults().valueForKey(HNThemeDefaultsKey) != nil) {
            let k : AnyObject! = NSUserDefaults.standardUserDefaults().valueForKey(HNThemeDefaultsKey)
            _Instance = _Themes[k.integerValue]
        } else {
            _Instance = _Themes[0]
        }
    }
    
    // MARK: - All Themes
    class var Themes: [HNTheme] {
        return _Themes;
    }
    
    class var FreeThemes: [HNTheme] {
        return _FreeThemes;
    }
    
    class var ProThemes: [HNTheme] {
        return _ProThemes;
    }
    
    // MARK: - Set Theme
    class func changeTheme(index: Int) {
        _Instance = _Themes[index]
        NSUserDefaults.standardUserDefaults().setValue(index, forKey: HNThemeDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(HNThemeChangeNotificationKey, object: nil)
    }
    
    // Readability
    class func readabilityIsActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HNReadabilityDefaultsKey)
    }
    
    class func readability(on: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(on, forKey: HNReadabilityDefaultsKey)
        NSNotificationCenter.defaultCenter().postNotificationName(HNReadabilityDidChangeNotification, object: nil)
    }
    
    // Mark As Read
    class func markAsReadIsActive() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HNMarkAsReadDefaultsKey)
    }
    
    class func markAsRead(on: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(on, forKey: HNMarkAsReadDefaultsKey)
        NSNotificationCenter.defaultCenter().postNotificationName(HNMarkAsReadDidChangeNotification, object: nil)
    }
}
