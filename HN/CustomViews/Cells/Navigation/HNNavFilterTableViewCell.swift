//
//  HNNavFilterTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavFilterTableViewCellIdentifier = "HNNavFilterTableViewCellIdentifier"

class HNNavFilterTableViewCell: UITableViewCell {
    var currentFilterType: Int? = 0
    
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
    
    func didSelectFilterButton(sender: UIButton) {
        HNNavigationBrain.navigateToPosts(PostFilterType.fromRaw(sender.tag)!)
        currentFilterType = sender.tag
        updateUI()
    }
    
    func updateUI() {
        for (view) in subviews[0].subviews {
            if (view.isKindOfClass(UIButton.self)) {
                var b = view as UIButton
                b.setTitleColor((b.tag == currentFilterType ? HNOrangeColor : UIColor.whiteColor()), forState: UIControlState.Normal)
            }
        }
    }

}
