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

@class SatelliteStore;


typedef void (^GetProductsCompletion) (BOOL success, NSArray * products, NSError * error);
typedef void (^PurchaseProductCompletion) (BOOL purchased, NSString * productIdentifier, SKPaymentTransaction * transaction, NSError * error);
typedef void (^RestoreProductsCompletion) (NSArray * productIdentifiers, NSError * error);

@interface SatellitePurchaseBlockObject : NSObject

@property (nonatomic, strong) NSString * productIdentifier;
@property (copy) PurchaseProductCompletion completionBlock;

+(SatellitePurchaseBlockObject *)purchaseBlockObjectForProductIdentifier:(NSString *)productIdentifier withCompletion:(PurchaseProductCompletion)completion;
@end

@interface SatelliteGetProductsBlockObject : NSObject

@property (nonatomic, strong) NSArray * productIdentifiers;
@property (copy) GetProductsCompletion  completionBlock;
@property (nonatomic, strong, readonly) SKProductsRequest * productRequest;

+(SatelliteGetProductsBlockObject *)getBlockObjectForProductIdentifiers:(NSArray *)productIdentifiers withCompletion:(GetProductsCompletion)completion;

-(id)initWithProductIdentifiers:(NSArray *)productIdentifiers;
@end

// Class
@interface SatelliteStore : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic, retain) NSMutableDictionary *Inventory;
@property (nonatomic, retain) NSSet *InventoryIdentifiers;
@property (nonatomic, strong) NSMutableArray * fetchProductsCompletionBlockObjects;
@property (nonatomic, strong) NSMutableArray * purchaseCompletionBlockObjects;
@property (nonatomic, strong, readonly) RestoreProductsCompletion restoreProductsCompletion;


// Singleton
+ (SatelliteStore *)shoppingCenter;

// Get Products
- (void)getProductsWithIdentifiers:(NSArray *)productIdentifiers withCompletion:(GetProductsCompletion)completion;

// Get Single Product
-(void)getProductWithIdentifier:(NSString *)productIdentifier withCompletion:(GetProductsCompletion)completion;

// Purchase Products
- (void)purchaseProductWithIdentifier:(NSString *)identifier withCompletion:(PurchaseProductCompletion)completion;

// Restore Purchases
- (void)restorePurchasesWithCompletion:(RestoreProductsCompletion)completion;

//Check if user can make purchase
-(BOOL)isOpenForBusiness;

@end
