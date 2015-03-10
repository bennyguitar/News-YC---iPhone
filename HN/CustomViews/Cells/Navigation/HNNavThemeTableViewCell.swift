//
//  HNNavThemeTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavThemeTableViewCellIdentifier = "HNNavThemeTableViewCellIdentifier"

class HNNavThemeTableViewCell: UITableViewCell {
    var currentThemeType: Int? = HNThemeManager.Theme.Index
    
    // TableView Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUI()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    func didSelectThemeButton(sender: UIButton) {
        HNThemeManager.changeTheme(sender.tag)
        currentThemeType = sender.tag
        updateUI()
    }
    
    func updateUI() {
        for (view) in subviews[0].subviews {
            if (view.isKindOfClass(UIButton.self)) {
                var b = view as UIButton
                b.setTitleColor((b.tag == currentThemeType ? HNOrangeColor : UIColor.whiteColor()), forState: UIControlState.Normal)
            }
        }
    }
}
