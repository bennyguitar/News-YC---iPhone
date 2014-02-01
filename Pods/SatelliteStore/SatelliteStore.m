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

#import "SatelliteStore.h"

@implementation SatelliteStore

static SatelliteStore * _shoppingCenter = nil;

#pragma mark - Singleton Creation
+ (SatelliteStore *)shoppingCenter {
	@synchronized([SatelliteStore class]) {
		if (!_shoppingCenter)
            _shoppingCenter  = [[SatelliteStore alloc]init];
		return _shoppingCenter;
	}
	return nil;
}


+ (id)alloc {
	@synchronized([SatelliteStore class]) {
		NSAssert(_shoppingCenter == nil, @"Attempted to allocate a second instance of a singleton.");
		_shoppingCenter = [super alloc];
		return _shoppingCenter;
	}
	return nil;
}


- (id)init {
	if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.Inventory = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - Set Product IDs
- (void)setProductIdentifiers:(NSArray *)identifiers {
    self.InventoryIdentifiers = [NSSet setWithArray:identifiers];
}

#pragma mark - Get Products
- (void)getProducts {
    self.ProductsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.InventoryIdentifiers];
    self.ProductsRequest.delegate = self;
    [self.ProductsRequest start];
}

- (void)getProductsWithCompletion:(GetProductsCompletion)completion {
    // Set Completion
    if (completion) {
        self.getProductsCompletion = completion;
        
        // Get Products
        [self getProducts];
    }
}

#pragma mark - Restore Purchases
- (void)restorePurchasesWithCompletion:(PurchaseProductCompletion)completion {
    if (completion) {
        self.purchaseCompletion = completion;
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

#pragma mark - Buy a Product
- (void)purchaseProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)purchaseProductWithIdentifier:(NSString *)identifier withCompletion:(PurchaseProductCompletion)completion {
    // Get Product from Inventory
    SKProduct *product = [self productFromInventoryWithIdentifier:identifier];
    
    // Purchase the product if it's valid
    if (completion) {
        self.purchaseCompletion = completion;
        
        if (product && [self isOpenForBusiness]) {
            [self purchaseProduct:product];
        }
        else {
            completion(NO);
        }
    }
}


#pragma mark - Receive Products back from Apple
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // Set Inventory
    if (response.products) {
        [self setInventoryWithProducts:response.products];
    }
    
    // Completion
    if (self.getProductsCompletion) {
        self.getProductsCompletion(response.products ? YES : NO);
    }
}


#pragma mark - Payment Queue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    //
}

#pragma mark - Payment Notifications
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //Remove the transaction observer so there is no chance to send notification to nil object
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    // Completion
    if (self.purchaseCompletion) {
        self.purchaseCompletion(wasSuccessful);
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [self finishTransaction:transaction wasSuccessful:NO];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}


#pragma mark - Inventory
- (void)setInventoryWithProducts:(NSArray *)products {
    [products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SKProduct class]]) {
            [self.Inventory setObject:obj forKey:[(SKProduct *)products[idx] productIdentifier]];
        }
    }];
}

- (SKProduct *)productFromInventoryWithIdentifier:(NSString *)identifier {
    if (self.Inventory[identifier]) {
        return self.Inventory[identifier];
    }
    
    return nil;
}

#pragma mark - Open for Business
- (BOOL)isOpenForBusiness {
    return [SKPaymentQueue canMakePayments];
}



@end
