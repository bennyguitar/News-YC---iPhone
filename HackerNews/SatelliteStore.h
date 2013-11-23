// Copyright (C) 2013 by Benjamin Gordon
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kProProductID @"com.subvertllc.HackerNews.Pro"

@class SatelliteStore;


typedef void (^GetProductsCompletion) (BOOL success);
typedef void (^PurchaseProductCompletion) (BOOL purchased);

// Class
@interface SatelliteStore : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *ProductsRequest;
@property (nonatomic, retain) NSMutableDictionary *Inventory;
@property (nonatomic, retain) NSSet *InventoryIdentifiers;
@property (nonatomic, strong) PurchaseProductCompletion purchaseCompletion;
@property (nonatomic, strong) GetProductsCompletion getProductsCompletion;


// Singleton
+ (SatelliteStore *)shoppingCenter;

// Set Product Identifiers
- (void)setProductIdentifiers:(NSArray *)identifiers;

// Get Products
- (void)getProductsWithCompletion:(GetProductsCompletion)completion;

// Purchase Products
- (void)purchaseProductWithIdentifier:(NSString *)identifier withCompletion:(PurchaseProductCompletion)completion;

// Restore Purchases
- (void)restorePurchasesWithCompletion:(PurchaseProductCompletion)completion;

// Inventory
- (SKProduct *)productFromInventoryWithIdentifier:(NSString *)identifier;
- (BOOL)inventoryHasProducts;

// Can Make Purchases
- (BOOL)isOpenForBusiness;


@end
