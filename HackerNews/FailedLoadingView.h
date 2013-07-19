//
//  FailedLoadingView.h
//  
//
//  Created by Ben Gordon on 4/3/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FailedLoadingView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *FailedImage;
@property (weak, nonatomic) IBOutlet UILabel *FailedText;

+(void)launchFailedLoadingInView:(UIView *)view;
+(void)launchFailedLoadingInView:(UIView *)view withImage:(UIImage *)image text:(NSString *)text duration:(float)time;

@end
