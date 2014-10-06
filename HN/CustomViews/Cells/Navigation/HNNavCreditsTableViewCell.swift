//
//  HNNavCreditsTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavCreditsTableViewCellIdentifier = "HNNavCreditsTableViewCellIdentifier"

class HNNavCreditsTableViewCell: UITableViewCell {
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var yCombinatorButton: UIButton!
    
    // TableView Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        for button in [githubButton,twitterButton,yCombinatorButton] {
            button.setImage(button.imageView?.image?.imageWithNewColor(HNOrangeColor), forState: UIControlState.Normal)
        }
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    @IBAction func didSelectGithubButton(sender: AnyObject) {
        HNNavigationBrain.navigateToWebViewController("https://github.com/bennyguitar")
    }
    @IBAction func didSelectTwitterButton(sender: AnyObject) {
        HNNavigationBrain.navigateToWebViewController("https://twitter.com/bennyguitar")
    }
    @IBAction func didSelectYCombinatorButton(sender: AnyObject) {
        HNNavigationBrain.navigateToWebViewController("https://news.ycombinator.com/user?id=bennyg")
    }
    @IBAction func didSelectAppButton(sender: AnyObject) {
        HNNavigationBrain.navigateToWebViewController("https://github.com/bennyguitar/News-YC---iPhone")
    }
}
