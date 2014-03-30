![Banner](https://raw.github.com/bennyguitar/SatelliteStore/master/banner.png)

SatelliteStore
==============

SatelliteStore is a modernized block-based StoreKit wrapper for iOS with very little set-up necessary to start letting users buy your in-app purchases, and for you to start making money! SatelliteStore is a singleton class that handles all interactions with the StoreKit framework you need in your app.

## Table of Contents

* [Installation](#installation)
* [Set Up](#set-up)
* [Purchasing a Product](#purchasing-a-product)
* [Restoring Purchases](#restoring-purchases)
* [Auxiliary Methods](#auxiliary-methods)
* [License](#license)

## Installation

**Cocoapods** 

[What's cocoapods?](http://cocoapods.com)

<code>pod 'SatelliteStore'</code>

**Adding Files**

All you need to do is add the <code>SatelliteStore.{h,m}</code> files from the top-level directory into your project. Then, to use the Store in a controller or class, just add <code>#import "SatelliteStore.h"</code> to your other imports. Now you're ready to blast off!

## Set Up

The inventory is no longer needed so you do not need to set the product identifiers. 

## Purchasing a Product

There is only one method used to buy a product, and you need to make sure you have done the stuff in the Set Up step above this before you call this method. Here's how you purchase a product:

```objc
[[SatelliteStore shoppingCenter] purchaseProductWithIdentifier:@"com.YourApp.Product1"
                                        withCompletion:^(BOOL purchased, NSString *productIdentifier, SKPaymentTransaction *transaction, NSError *error) {
      if (purchased) {
          // Purchase Worked!
      }
      else {
      		if(transaction.error.code == SKErrorPaymentCancelled){
      			//user cancelled purchase
      		}else{
      		// Handle failure
      		}   
      }
}];
```

## Restoring Purchases

Similar to purchasing a product, there is only one method you should call to restore your purchases inside of the app:

```objc
[[SatelliteStore shoppingCenter] restorePurchasesWithCompletion:^(NSArray *productIdentifiers, NSError * error) {
      if (!error) {
          // Restore Worked!
      }
      else {
          // Handle failure
      }
}];
```

## Auxiliary Methods

There are a couple methods you can hit that offer some additional functionality if you'd like. You can also bind to the <code>isOpenForBusiness</code> method that returns a BOOL of whether purchases are allowed or not (parental controls, etc).

## License

SatelliteStore is licensed under the standard MIT License:

**Copyright (C) 2013 by Benjamin Gordon**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
