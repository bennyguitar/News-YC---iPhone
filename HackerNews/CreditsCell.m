//
//  CreditsCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/20/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "CreditsCell.h"

#define kBTCAddress @"172uHpvuFochdrDWNdt7rwhX32SYm5QF9K"

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
    [self.btcButton addTarget:self action:@selector(didSelectDonateBTC) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didSelectGitHubButton {
    if ([self.delegate respondsToSelector:@selector(didClickGitHubLink)]) {
        [self.delegate didClickGitHubLink];
    }
}

- (void)didSelectDonateBTC {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Donate Bitcoin" message:[NSString stringWithFormat:@"You can send all BTC donations to:\n\n%@", kBTCAddress] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}


@end
