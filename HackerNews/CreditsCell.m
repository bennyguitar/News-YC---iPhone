//
//  CreditsCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/20/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "CreditsCell.h"

@implementation CreditsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithDelegate:(id<CreditsCellDelegate>)delegate {
    self.delegate = delegate;
    [self.githubButton addTarget:self action:@selector(didSelectGitHubButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didSelectGitHubButton {
    if ([self.delegate respondsToSelector:@selector(didClickGitHubLink)]) {
        [self.delegate didClickGitHubLink];
    }
}

@end
