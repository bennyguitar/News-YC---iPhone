// Copyright (C) 2014 by Benjamin Gordon
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "BTCDonationViewController.h"
#import <BGUtilities.h>
#import <Colours.h>

#pragma mark - Static Strings
NSString * const kBTCDonationUIKeyBackgroundColor = @"kBTCDonationUIKeyBackgroundColor";
NSString * const kBTCDonationUIKeyHeaderTopTextColor = @"kBTCDonationUIKeyHeaderTopTextColor";
NSString * const kBTCDonationUIKeyHeaderTopTextFont = @"kBTCDonationUIKeyHeaderTopTextFont";
NSString * const kBTCDonationUIKeyHeaderTopTextString = @"kBTCDonationUIKeyHeaderTopTextString";
NSString * const kBTCDonationUIKeyHeaderBottomTextColor = @"kBTCDonationUIKeyHeaderBottomTextColor";
NSString * const kBTCDonationUIKeyHeaderBottomTextFont = @"kBTCDonationUIKeyHeaderBottomTextFont";
NSString * const kBTCDonationUIKeyHeaderBottomTextString = @"kBTCDonationUIKeyHeaderBottomTextString";
NSString * const kBTCDonationUIKeyFooterTextColor = @"kBTCDonationUIKeyFooterTextColor";
NSString * const kBTCDonationUIKeyFooterTextFont = @"kBTCDonationUIKeyFooterTextFont";
NSString * const kBTCDonationUIKeyFooterTextString = @"kBTCDonationUIKeyFooterTextString";
NSString * const kBTCDonationUIKeyAddressLinkColor = @"kBTCDonationUIKeyAddressLinkColor";
NSString * const kBTCDonationUIKeyAddressLinkFont = @"kBTCDonationUIKeyAddressLinkFont";
NSString * const kBTCDonationUIKeyQRColor = @"kBTCDonationUIKeyQRColor";


#pragma mark - Interface
@interface BTCDonationViewController ()
// UI
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UILabel *headerTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrImageBottomConstraint;
// Data
@property (nonatomic, strong) NSString *btcAddress;
@property (nonatomic, strong) NSDictionary *uiOptions;
@end


#pragma mark - Implementation
@implementation BTCDonationViewController

#pragma mark - Init
+ (instancetype)newControllerWithBTCAddress:(NSString *)btcAddress
{
    return [self newControllerWithBTCAddress:btcAddress options:@{}];
}

+ (instancetype)newControllerWithBTCAddress:(NSString *)btcAddress options:(NSDictionary *)uiOptions
{
    return [[self alloc] initWithNibName:@"BTCDonationViewController" bundle:nil address:btcAddress options:uiOptions];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil address:(NSString *)btcAddress options:(NSDictionary *)uiOptions
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.btcAddress = btcAddress;
        self.uiOptions = uiOptions;
    }
    return self;
}



#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
- (void)setUI {
    // Set Up
    NSDictionary *headerTopTextDict = [self attributesForKeys:@[kBTCDonationUIKeyHeaderTopTextColor, kBTCDonationUIKeyHeaderTopTextFont]];
    NSDictionary *headerBottomTextDict = [self attributesForKeys:@[kBTCDonationUIKeyHeaderBottomTextColor, kBTCDonationUIKeyHeaderBottomTextFont]];
    NSDictionary *footerTextDict = [self attributesForKeys:@[kBTCDonationUIKeyFooterTextColor, kBTCDonationUIKeyFooterTextFont]];
    NSDictionary *addressLinkDict = [self attributesForKeys:@[kBTCDonationUIKeyAddressLinkColor, kBTCDonationUIKeyAddressLinkFont]];
    UIColor *qrColor = (self.uiOptions[kBTCDonationUIKeyQRColor] && [self.uiOptions[kBTCDonationUIKeyQRColor] isKindOfClass:[UIColor class]]) ? self.uiOptions[kBTCDonationUIKeyQRColor] : [UIColor blackColor];
    UIColor *backgroundColor = (self.uiOptions[kBTCDonationUIKeyBackgroundColor] && [self.uiOptions[kBTCDonationUIKeyBackgroundColor] isKindOfClass:[UIColor class]]) ? self.uiOptions[kBTCDonationUIKeyBackgroundColor] : [UIColor whiteColor];
    NSString *headerTopString = (self.uiOptions[kBTCDonationUIKeyHeaderTopTextString] && [self.uiOptions[kBTCDonationUIKeyHeaderTopTextString] isKindOfClass:[NSString class]]) ? self.uiOptions[kBTCDonationUIKeyHeaderTopTextString] : @"Support the App!";
    NSString *headerBottomString = (self.uiOptions[kBTCDonationUIKeyHeaderBottomTextString] && [self.uiOptions[kBTCDonationUIKeyHeaderBottomTextString] isKindOfClass:[NSString class]]) ? self.uiOptions[kBTCDonationUIKeyHeaderBottomTextString] : @"Donate bitcoin today.";
    NSString *footerString = (self.uiOptions[kBTCDonationUIKeyFooterTextString] && [self.uiOptions[kBTCDonationUIKeyFooterTextString] isKindOfClass:[NSString class]]) ? self.uiOptions[kBTCDonationUIKeyFooterTextString] : @"Tap to copy address.";
    
    // Set Attributes
    [self.headerTopLabel setAttributedText:[[NSAttributedString alloc] initWithString:headerTopString attributes:headerTopTextDict]];
    [self.headerBottomLabel setAttributedText:[[NSAttributedString alloc] initWithString:headerBottomString attributes:headerBottomTextDict]];
    [self.footerLabel setAttributedText:[[NSAttributedString alloc] initWithString:footerString attributes:footerTextDict]];
    [self.addressButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.btcAddress attributes:addressLinkDict] forState:UIControlStateNormal];
    self.view.backgroundColor = backgroundColor;
    
    // Create QR Code
    [self addQRCodeForAddress:self.btcAddress withColor:qrColor toImageView:self.qrImageView];
    
    // Set Background
    [self.view setBackgroundColor:backgroundColor];
    
    // Resize if necessary
    if ([BGSystemUtilities screenHeight] == 480) {
        //3.5in screen
        float offsetAmount = 88;
        [self.qrImageTopConstraint setConstant:self.qrImageTopConstraint.constant - offsetAmount/2];
        [self.qrImageBottomConstraint setConstant:self.qrImageBottomConstraint.constant - offsetAmount/2];
    }
    
}

- (NSDictionary *)attributesForKeys:(NSArray *)keys {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        if (self.uiOptions[key]) {
            NSString *newKey = @"";
            Class newKeyClass = [NSObject class];
            if ([key contains:@"Color"]) {
                newKey = NSForegroundColorAttributeName;
                newKeyClass = [UIColor class];
            }
            else if ([key contains:@"Font"]) {
                newKey = NSFontAttributeName;
                newKeyClass = [UIFont class];
            }
            
            if ([self.uiOptions[key] isKindOfClass:newKeyClass]) {
                [attributes setObject:self.uiOptions[key] forKey:newKey];
            }
        }
    }
    
    return attributes;
}

- (void)showCopiedText {
    
}


#pragma mark - Copy Address
- (IBAction)didSelectCopyAddressButton:(UIButton *)sender {
    [[UIPasteboard generalPasteboard] setString:self.btcAddress];
    [self showCopiedText];
}


#pragma mark - Create QR Code
// generate QR code via Core Image
- (void)addQRCodeForAddress:(NSString *)address withColor:(UIColor *)color toImageView:(UIImageView *)imgView {
    NSData *qrData = [address dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:qrData
                forKey:@"inputMessage"];
    CIImage *unscaledImage = qrFilter.outputImage;
    
    // transition CIImage to CGImage and enlarge it
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:unscaledImage fromRect:[unscaledImage extent]];
    UIGraphicsBeginImageContext(CGSizeMake((NSInteger)imgView.frame.size.width, (NSInteger)imgView.frame.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *upscaledQR = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // update the image view
    UIImage *minusWhiteQR = [upscaledQR imageByReplacingColorsWithinDistance:10 fromColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] withColor:[UIColor clearColor]];
    UIImage *flippedImage = [self flipImageVertically:[minusWhiteQR imageWithNewColor:color]];
    imgView.image = flippedImage;
}

- (UIImage *)flipImageVertically:(UIImage *)originalImage {
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:originalImage];
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, tempImageView.frame.size.height);
    CGContextConcatCTM(context, flipVertical);
    [[tempImageView layer] renderInContext:context];
    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flipedImage;
}


@end
