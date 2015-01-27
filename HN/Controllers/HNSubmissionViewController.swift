//
//  HNSubmissionViewController.swift
//  HN
//
//  Created by Ben Gordon on 10/5/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

enum HNSubmissionType: Int {
    case NewPost, PostReply, CommentReply
}

let HNSubmissionFormPostTitle = "HNSubmissionFormPostTitle"
let HNSubmissionFormPostUrl = "HNSubmissionFormPostUrl"
let HNSubmissionFormPostText = "HNSubmissionFormPostText"
let HNSubmissionFormCommentText = "HNSubmissionFormCommentText"

class HNSubmissionViewController: XLFormViewController {
    var currentSubmissionType: HNSubmissionType? = .NewPost
    var currentHNObject: AnyObject? = nil
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init!(form: XLFormDescriptor!, style: UITableViewStyle) {
        super.init(form: form, style: style)
    }
    
    init(hnObject: AnyObject?)  {
        var submissionType = HNSubmissionType.NewPost
        if (hnObject != nil) {
            if (hnObject!.isKindOfClass(HNPost.self)) {
                submissionType = .PostReply
            }
            else if (hnObject!.isKindOfClass(HNComment.self)) {
                submissionType = .CommentReply
            }
        }
        var formDescriptor = XLFormDescriptor(title: nil)
        
        // New Post
        if (submissionType == .NewPost) {
            var section: XLFormSectionDescriptor = XLFormSectionDescriptor.formSectionWithTitle("Submission") as XLFormSectionDescriptor
            section.footerTitle = "Each submission must have a title, and either a URL or the body text for a self post."
            formDescriptor.addFormSection(section)
            
            var row = XLFormRowDescriptor(tag: HNSubmissionFormPostTitle, rowType: "text", title: "Title")
            row.required = false
            HNSubmissionViewController.setStyleForTextFieldRow(row)
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: HNSubmissionFormPostUrl, rowType: "url", title: "URL")
            row.required = false
            HNSubmissionViewController.setStyleForTextFieldRow(row)
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: HNSubmissionFormPostText, rowType: "textView", title: "Text")
            row.required = false
            HNSubmissionViewController.setStyleForTextViewRow(row)
            section.addFormRow(row)
        }
        
        // Reply
        else {
            var section: XLFormSectionDescriptor = XLFormSectionDescriptor.formSectionWithTitle("Reply") as XLFormSectionDescriptor
            section.footerTitle = "Be engaging."
            formDescriptor .addFormSection(section)
            
            var row = XLFormRowDescriptor(tag: HNSubmissionFormCommentText, rowType: "textView", title: "Text")
            row.required = false
            HNSubmissionViewController.setStyleForTextViewRow(row)
            section.addFormRow(row)
        }
        
        // Data
        currentHNObject = hnObject
        currentSubmissionType = submissionType
        
        super.init(form: formDescriptor)
    }
    
    class func setStyleForTextFieldRow(row: XLFormRowDescriptor) {
        row.cellConfigAtConfigure.setObject(HNTheme.currentTheme().colorForUIElement(.Bar), forKey: "backgroundColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.Bar), forKey: "textField.backgroundColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.MainFont), forKey: "textField.textColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.SubFont), forKey: "textLabel.textColor")
    }
    
    class func setStyleForTextViewRow(row: XLFormRowDescriptor) {
        row.cellConfigAtConfigure.setObject(HNTheme.currentTheme().colorForUIElement(.Bar), forKey: "backgroundColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.Bar), forKey: "textView.backgroundColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.MainFont), forKey: "textView.textColor")
        row.cellConfig.setObject(HNTheme.currentTheme().colorForUIElement(.SubFont), forKey: "label.textColor")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "didSelectSaveForm:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didSelectCancel:")
        tableView.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        tableView.separatorColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.SubFont)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        tableView.updateConstraints()
    }
    
    func setSaveUI(saving: Bool) {
        if (saving) {
            navigationItem.rightBarButtonItem = nil
        }
        else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "didSelectSaveForm:")
        }
    }
    
    func didSelectSaveForm(btn: UIBarButtonItem) {
        // Save UI
        setSaveUI(true)
        
        if (currentSubmissionType == .NewPost) {
            var formValues = form.formValues()
            println("\(formValues)")
            var title = formValues[HNSubmissionFormPostTitle]! as? String
            let url = formValues[HNSubmissionFormPostUrl]! as? String
            let text = formValues[HNSubmissionFormPostText]! as? String
            HNManager.sharedManager().submitPostWithTitle(title, link: url, text: text, completion: { [weak self](success) -> Void in
                if (success) {
                    if (self != nil) {
                        self!.navigationController?.popViewControllerAnimated(true)
                    }
                    BGUtils.showSuccessMessage("Post Successful!")
                }
                else {
                    if (self != nil) {
                        self!.setSaveUI(false)
                    }
                    BGUtils.showFailureMessate("Post Failed!")
                }
            })
        }
        
        else {
            var formValues = form.formValues()
            let text = formValues[HNSubmissionFormCommentText]! as? String
            HNManager.sharedManager().replyToPostOrComment(currentHNObject, withText: text, completion: { [weak self](success) -> Void in
                if (success) {
                    if (self != nil) {
                        self!.navigationController?.popViewControllerAnimated(true)
                    }
                    BGUtils.showSuccessMessage("Comment Successful!")
                }
                else {
                    if (self != nil) {
                        self!.setSaveUI(false)
                    }
                    BGUtils.showFailureMessate("Comment Failed!")
                }
            })
        }
        
        tableView.endEditing(true)
        // Do Something here
    }
    
    func didSelectCancel(btn: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var row = form.formRowAtIndex(indexPath)
        if (row.tag == HNSubmissionFormPostTitle || row.tag == HNSubmissionFormPostUrl) {
            return 50.0
        }
        
        return 200.0
    }
}
