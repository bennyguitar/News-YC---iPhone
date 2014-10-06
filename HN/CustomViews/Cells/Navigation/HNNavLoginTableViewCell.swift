//
//  HNNavLoginTableViewCell.swift
//  HN
//
//  Created by Ben Gordon on 9/30/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let HNNavLoginTableViewCellIdentifier = "HNNavLoginTableViewCellIdentifier"

class HNNavLoginTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: HNTextField!
    @IBOutlet weak var passwordTextField: HNTextField!
    
    // TableView Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.setNeedsDisplay()
        passwordTextField.setNeedsDisplay()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    func setUIForLoggingIn(loggingIn: Bool) {
        usernameTextField.alpha = loggingIn ? 0.25 : 1.0
        passwordTextField.alpha = loggingIn ? 0.25 : 1.0
    }
    
    // TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            passwordTextField.becomeFirstResponder()
        }
        else {
            // Login
            setUIForLoggingIn(true)
            HNManager.sharedManager().loginWithUsername(usernameTextField.text, password: passwordTextField.text, completion: { [weak self](user) -> Void in
                if (user != nil) {
                    NSNotificationCenter.defaultCenter().postNotificationName(HNDidLoginOrOutNotification, object: nil)
                }
                if (self != nil) {
                    self!.setUIForLoggingIn(false)
                }
            })
            textField.endEditing(true)
        }
        
        return true
    }
}
