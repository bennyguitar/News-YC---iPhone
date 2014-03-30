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

#import <UIKit/UIKit.h>


#pragma mark - Static Strings
extern NSString * const kBTCDonationUIKeyBackgroundColor;
extern NSString * const kBTCDonationUIKeyHeaderTopTextColor;
extern NSString * const kBTCDonationUIKeyHeaderTopTextFont;
extern NSString * const kBTCDonationUIKeyHeaderTopTextString;
extern NSString * const kBTCDonationUIKeyHeaderBottomTextColor;
extern NSString * const kBTCDonationUIKeyHeaderBottomTextFont;
extern NSString * const kBTCDonationUIKeyHeaderBottomTextString;
extern NSString * const kBTCDonationUIKeyFooterTextColor;
extern NSString * const kBTCDonationUIKeyFooterTextFont;
extern NSString * const kBTCDonationUIKeyFooterTextString;
extern NSString * const kBTCDonationUIKeyAddressLinkColor;
extern NSString * const kBTCDonationUIKeyAddressLinkFont;
extern NSString * const kBTCDonationUIKeyQRColor;

#pragma mark - Interface
@interface BTCDonationViewController : UIViewController

#pragma mark - Init
/**
 *  Creates a new BTCDonationViewController
 *
 *  @param btcAddress NSString
 *
 *  @return BTCDonationViewController
 */
+ (instancetype)newControllerWithBTCAddress:(NSString *)btcAddress;

/**
 *  Creates a new BTCDonationViewController with an NSDictionary of UI options. The keys available for use use the following pattern: BTCDonationUIKeyXXX
 *
 *  @param btcAddress NSString
 *  @param uiOptions  NSDictionary
 *
 *  @return BTCDonationViewController
 */
+ (instancetype)newControllerWithBTCAddress:(NSString *)btcAddress options:(NSDictionary *)uiOptions;

/**
 *  Creates a new BTCDonationViewController using a nib, a BTC Public Address, and UI options. The keys available for use adhere to the following pattern: BTCDonationUIKeyXXX
 *
 *  @param nibNameOrNil   NSString
 *  @param nibBundleOrNil NSBundle
 *  @param btcAddress     NSString
 *  @param uiOptions      NSDictionary
 *
 *  @return BTCDonationViewController
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil address:(NSString *)btcAddress options:(NSDictionary *)uiOptions;

@end
