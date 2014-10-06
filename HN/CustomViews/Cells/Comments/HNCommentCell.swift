//
//  HNCommentCell.swift
//  HN
//
//  Created by Ben Gordon on 9/19/14.
//  Copyright (c) 2014 bennyguitar. All rights reserved.
//

import UIKit

let horizCommentSpaceStart = 8.0
let commentLevelSpace = 15.0

protocol HNCommentsCellDelegate {
    func didSelectHideNested(index: Int, level: Int)
}

enum HNCommentCellVisibility: Int {
    case Visible, Closed, Hidden
}

class HNCommentCell: UITableViewCell, TTTAttributedLabelDelegate {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: TTTAttributedLabel!
    @IBOutlet weak var topBarLeftSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentLabelLeftSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    var commentLevel = 0
    var index = 0
    var del: HNCommentsCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: false)
    }
    
    func setContentWithComment(comment: HNComment, indexPath: NSIndexPath, delegate: HNCommentsCellDelegate, visibility: HNCommentCellVisibility) {
        // Data
        usernameLabel.text = comment.Username
        timeLabel.text = comment.TimeCreatedString
        commentLevel = Int(comment.Level)
        index = indexPath.row
        del = delegate
        
        // Visibility
        if (visibility == HNCommentCellVisibility.Closed) {
            setContentViewForVisibility(HNCommentCellVisibility.Closed)
            topBar.backgroundColor = HNOrangeColor
            return
        }
        else if (visibility == HNCommentCellVisibility.Hidden) {
            setContentViewForVisibility(HNCommentCellVisibility.Hidden)
            topBar.backgroundColor = UIColor.redColor()
            return
        }
        
        setContentViewForVisibility(HNCommentCellVisibility.Visible)
        
        // Links
        commentLabel.delegate = self
        commentLabel.linkAttributes = [kCTForegroundColorAttributeName:HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.CommentLinkColor), kCTUnderlineStyleAttributeName:NSUnderlineStyle.StyleNone.toRaw()]
        commentLabel.activeLinkAttributes = [kCTForegroundColorAttributeName:HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.CommentLinkColor), kCTUnderlineStyleAttributeName:NSUnderlineStyle.StyleNone.toRaw(), kCTFontAttributeName:UIFont.boldSystemFontOfSize(14.0)]
        commentLabel.setText(comment.Text, afterInheritingLabelAttributesAndConfiguringWithBlock: { (aString) -> NSMutableAttributedString! in
            aString.addAttributes([kCTForegroundColorAttributeName:HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.MainFont), kCTFontAttributeName:UIFont.systemFontOfSize(14.0), NSBackgroundColorAttributeName: HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)], range: NSMakeRange(0, NSString(string: comment.Text).length))
            return aString
        })
        for link in comment.Links {
            commentLabel.addLinkToURL(link.Url, withRange: link.UrlRange)
        }
        
        // UI
        backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.BackgroundColor)
        topBar.backgroundColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.Bar)
        usernameLabel.backgroundColor = topBar!.backgroundColor
        timeLabel.backgroundColor = topBar!.backgroundColor
        usernameLabel.textColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.SubFont)
        timeLabel.textColor = HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.SubFont)
        
        // Constraints
        commentLabelLeftSpaceConstraint.constant = CGFloat(comment.Level) * CGFloat(commentLevelSpace) + CGFloat(horizCommentSpaceStart)
        topBarLeftSpaceConstraint.constant = CGFloat(comment.Level) * CGFloat(commentLevelSpace)
    }
    
    override func drawRect(rect: CGRect) {
        // Create comment level lines
        for (var xx = 0; xx < commentLevel + 1; xx++) {
            if (xx != 0) {
                var path = UIBezierPath()
                HNTheme.currentTheme().colorForUIElement(HNTheme.ThemeUIElement.Bar).setStroke()
                path.moveToPoint(CGPoint(x: 15*xx, y: 0))
                path.addLineToPoint(CGPoint(x: Double(15)*Double(xx), y: Double(rect.size.height)))
                path.stroke()
            }
        }
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        HNNavigationBrain.navigateToWebViewController(url.absoluteString!)
    }
    
    @IBAction func didSelectCommentsBar(sender: AnyObject) {
        del?.didSelectHideNested(index, level: commentLevel)
    }
    
    func setNested() {
        setContentViewForVisibility(HNCommentCellVisibility.Closed)
    }
    
    func setHidden() {
        setContentViewForVisibility(HNCommentCellVisibility.Hidden)
    }
    
    func setContentViewForVisibility(visibility: HNCommentCellVisibility) {
        /*
        switch (visibility) {
        case .Closed:
            topBarHeightConstraint.constant = 0.0
            topBarHeightConstraint.priority = 1000
            commentViewHeightConstraint.constant = 0.0
            commentViewHeightConstraint.priority = 1000
        case .Hidden:
            topBarHeightConstraint.constant = 18.0
            topBarHeightConstraint.priority = 1000
            commentViewHeightConstraint.constant = 0.0
            commentViewHeightConstraint.priority = 1000
        case .Visible:
            topBarHeightConstraint.constant = 18.0
            topBarHeightConstraint.priority = 100
            commentViewHeightConstraint.constant = 47.5
            commentViewHeightConstraint.priority = 100
        }
*/
    }
}
