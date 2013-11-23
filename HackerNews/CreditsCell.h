//
//  CreditsCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/20/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellCreditsHeight 183

@protocol CreditsCellDelegate <NSObject>

- (void)didClickGitHubLink;

@end

@interface CreditsCell : UITableViewCell

@property (weak) id <CreditsCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *githubButton;

- (void)setCellWithDelegate:(id<CreditsCellDelegate>)delegate;

@end
