![banner](/Images/banner-01.png)

## Installing

**Cocoapods (Coming Soon)**

`pod 'BTCDonationViewController'`

## Using

`BTCDonationViewController` is very simple to work with, you only need to make one call to get your View Controller, and then you can push to the navigation stack or display however you want. Just make sure you `#import <BTCDonationViewController.h>` in the class you want to use this in.

`BTCDonationViewController *btcVC = [BTCDonationViewController newControllerWithBTCAddress:@"1LvoCg2axTrjgmGN6qT9kKXTA1M3ckBKJL" options:nil];`

That's it. This gives you the stock `BTCDonationViewController`.

## Customizing

However, you may want to customize even further. This leaves us with the `options` parameter of the mian method. `BTCDonationViewController` can consume an `NSDictionary` for the options parameter, which can manipulate the entire UI of the controller. Check out the following graphic for all of the keys necessary.

![Fig1](/Images/figure1-01.png)

**Keys**

* `kBTCDonationUIKeyBackgroundColor` - `UIColor`
* `kBTCDonationUIKeyHeaderTopTextColor` - `UIColor`
* `kBTCDonationUIKeyHeaderTopTextFont` - `UIFont`
* `kBTCDonationUIKeyHeaderTopTextString` - `NSString`
* `kBTCDonationUIKeyHeaderBottomTextColor` - `UIColor`
* `kBTCDonationUIKeyHeaderBottomTextFont` - `UIFont`
* `kBTCDonationUIKeyHeaderBottomTextString` - `NSString`
* `kBTCDonationUIKeyFooterTextColor` - `UIColor`
* `kBTCDonationUIKeyFooterTextFont` - `UIFont`
* `kBTCDonationUIKeyFooterTextString` - `NSString`
* `kBTCDonationUIKeyAddressLinkColor` - `UIColor`
* `kBTCDonationUIKeyAddressLinkFont` - `UIFont`
* `kBTCDonationUIKeyQRColor` - `UIColor`

**What this looks like**

```objc
NSDictionary *uiOptions = @{kBTCDonationUIKeyBackgroundColor:[UIColor emeraldColor],
                            kBTCDonationUIKeyQRColor:[UIColor whiteColor],
                            kBTCDonationUIKeyHeaderTopTextColor:[UIColor whiteColor],
                            kBTCDonationUIKeyHeaderTopTextFont:[UIFont fontWithName:@"Futura" size:36.0f],
                            kBTCDonationUIKeyHeaderBottomTextColor:[UIColor whiteColor],
                            kBTCDonationUIKeyHeaderBottomTextFont:[UIFont fontWithName:@"Futura" size:18.0f],
                            kBTCDonationUIKeyFooterTextColor:[UIColor whiteColor],
                            kBTCDonationUIKeyFooterTextFont:[UIFont fontWithName:@"Futura" size:18.0f],
                            kBTCDonationUIKeyAddressLinkColor:[UIColor whiteColor],
                            kBTCDonationUIKeyAddressLinkFont:[UIFont fontWithName:@"Futura" size:14.0f]};
BTCDonationViewController *vc = [BTCDonationViewController newControllerWithBTCAddress:kDeveloperBTCAddress options:uiOptions];
```

![Fig2](/Images/figure2-01.png)

**Going even further**

To customize this even further, you can add properties and manipulate the included `.xib`file to customize to your heart's delight.

## What's Left

**Bugs**

`0.1.0`

I've noticed that it's a little slow on a device, so there may be some ways to make this even faster. My guess is that the root of the problem is in one of the [`BGUtilities`](https://github.com/bennyguitar/BGUtilities) UIImage category methods necessary for creating the QR code, and manipulating the pixel colors. I'm wondering if the best option is to keep a placeholder image for the QR code while it loads from a background thread to keep app responsiveness as snappy as possible.

**iPad**

There is no native iPad support, so an iPad ViewController version of this should be available in the future too.

## Demo

There is a demo project included in this repo. To run it, make sure you have [Cocoapods](http://cocoapods.org/) installed on your machine. Navigate to the directory of the demo project, and run this line in your Terminal:

`pod install`

This will set up your project with Cocoapods, install the prerequisites, and then create a `.xcworkspace` file that you will use to build and run the demo.

## License

> Copyright (C) 2014 by Benjamin Gordon

> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Donate

If you'd like to support me and my work, you can donate BTC here:

[`1LvoCg2axTrjgmGN6qT9kKXTA1M3ckBKJL`](https://blockchain.info/address/1LvoCg2axTrjgmGN6qT9kKXTA1M3ckBKJL)
