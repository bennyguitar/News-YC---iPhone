//
//  HNNavSettingsTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavSettingsTableViewCellIdentifier = "HNNavSettingsTableViewCellIdentifier"

class HNNavSettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var readabilityButton: UIButton!
    @IBOutlet weak var markAsReadButton: UIButton!
    
    // TableView Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    // UI
    func setUI() {
        readabilityButton.setTitleColor((HNThemeManager.readabilityIsActive() ? HNOrangeColor : UIColor.whiteColor()), forState: .Normal)
        markAsReadButton.setTitleColor((HNThemeManager.markAsReadIsActive() ? HNOrangeColor : UIColor.whiteColor()), forState: .Normal)
        
    }
    
    // Actions
    @IBAction func didSelectReadabilityButton(sender: AnyObject) {
        HNThemeManager.readability(!HNThemeManager.readabilityIsActive())
        setUI()
    }
    
    @IBAction func didSelectMarkAsReadButton(sender: AnyObject) {
        HNThemeManager.markAsRead(!HNThemeManager.markAsReadIsActive())
        setUI()
    }
    
}
