//
//  HNNavTableHeader.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

class HNNavTableHeader: UIView {
    @IBOutlet weak var headerLabel: UILabel!
    
    class func headerWithText(text: String) -> HNNavTableHeader {
        // Create View
        var header = HNNavTableHeader()
        header = NSBundle.mainBundle().loadNibNamed(BGUtils.className(HNNavTableHeader.self), owner: nil, options: nil)[0] as HNNavTableHeader
        
        // Set Data
        header.headerLabel.text = text.uppercaseString
        
        // Return it
        return header
    }
    
    class func height() -> CGFloat {
        return 34.0
    }
}
