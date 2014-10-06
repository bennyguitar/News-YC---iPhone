//
//  HNNavProfileTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavProfileTableViewCellIdentifier = "HNNavProfileTableViewCellIdentifier"

class HNNavProfileTableViewCell: UITableViewCell {
    // Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mySubmissionsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    // TableView Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setContentWithUser(HNManager.sharedManager().SessionUser)
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    // Content
    func setContentWithUser(user: HNUser?) {
        if (user != nil) {
            usernameLabel.text = "\(user!.Username) • \(user!.Karma)"
        }
    }
    
    // IBActions
    @IBAction func didSelectMySubmissions(sender: AnyObject) {
        HNNavigationBrain.navigateToPosts(HNManager.sharedManager().SessionUser.Username)
    }
    
    @IBAction func didSelectLogout(sender: AnyObject) {
        HNManager.sharedManager().logout()
    }
}
