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

All you need to do is add the <code>SatelliteStore.{h,m}</code> files from the top-level directory into your project. Then, to use the Store in a controller or class, just add <code>#import "SatelliteStore.h"</code> to your other imports. Now you're ready to blast off!

## Set Up

The SatelliteStore object has two methods necessary to fetch products from the iTunes App Store. I recommend calling this in your AppDelegate, so that by the time a user has a chance to make a purchase you have already populated the inventory. Since SatelliteStore is a singleton class, you'll be working with the <code>[SatelliteStore shoppingCenter]</code> app-wide instantiation. All methods should go through the shoppingCenter to make sure things work. Here's some code you should add to your <code>- (BOOL)application:didFinishLaunchingWithOptions:</code> method in the AppDelegate file:

```objc
// Satellite Store: Set Identifiers
[[SatelliteStore shoppingCenter] setProductIdentifiers:@[@"com.YourApp.ProductId1",@"com.YourApp.ProductId2"]];
        
// Satellite Store: Get Prodcuts
[[SatelliteStore shoppingCenter] getProductsWithCompletion:^(BOOL success) {
    //
}];
```

The first methods adds the product identifiers into an NSSet that the SatelliteStore then uses to make a query that actually finds the associated SKProduct items. The second method is that query, and returns a boolean of whether it worked or not. After calling this method, the SatelliteStore adds all of the returned products into its <code>Inventory</code>, a dictionary of ProductIds mapped to each SKProduct item. The reason this has a success callback is because if you try to purchase an item when no items have been retrieved, it obviously won't work. The success alerts you as a developer that products have been returned (if you have 0 items in iTunesConnect, then this will return YES, but the Inventory will be empty).

## Purchasing a Product

There is only one method used to buy a product, and you need to make sure you have done the stuff in the Set Up step above this before you call this method. Here's how you purchase a product:

```objc
[[SatelliteStore shoppingCenter] purchaseProductWithIdentifier:@"com.YourApp.ProductId1" withCompletion:^(BOOL success) {
      if (success) {
          // Purchase Worked!
      }
      else {
          // Handle failure
      }
}];
```

## Restoring Purchases

Similar to purchasing a product, there is only one method you should call to restore your purchases inside of the app:

```objc
[[SatelliteStore shoppingCenter] restorePurchasesWithCompletion:^(BOOL success) {
      if (success) {
          // Purchase Worked!
      }
      else {
          // Handle failure
      }
}];
```

## Auxiliary Methods

There are a couple methods you can hit that offer some additional functionality if you'd like. You can bind to the <code>productFromInventoryWithIdentifier:(NSString *)identifier</code> method to just grab an SKProduct item from the inventory if one exists with taht identifier. You can also bind to the <code>isOpenForBusiness</code> method that returns a BOOL of whether purchases are allowed or not (parental controls, etc).

## License

SatelliteStore is licensed under the standard MIT License:

**Copyright (C) 2013 by Benjamin Gordon**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
