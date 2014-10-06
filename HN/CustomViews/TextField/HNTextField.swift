//
//  HNTextField.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNTextField: UITextField {
    var placeholderColor: UIColor? = UIColor(white: 1.0, alpha: 0.35)
    
    override func drawPlaceholderInRect(rect: CGRect) {
        if (placeholderColor != nil) {
            var placeholderRect = CGRectMake(rect.origin.x, (rect.size.height - font.lineHeight)/2, rect.size.width, font.lineHeight);
            NSString(string: placeholder!).drawInRect(placeholderRect, withAttributes:[NSForegroundColorAttributeName:placeholderColor!, NSFontAttributeName:UIFont(name: "HelveticaNeue-Thin", size: 14.0)])
        }
    }
    
    override func drawRect(rect: CGRect) {
        addSubview(UIView.separatorWithWidth(Float(rect.size.width), origin: CGPointMake(0, CGFloat(height()) - 1), color: placeholderColor!))
    }
}
