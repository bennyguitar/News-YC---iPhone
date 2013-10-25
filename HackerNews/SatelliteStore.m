//
//  SatelliteStore.m
//  Red
//
//  Created by Benjamin Gordon on 4/27/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import "SatelliteStore.h"

@implementation SatelliteStore

#pragma mark - Init
- (instancetype)initWithDelegate:(id)del {
    self = [super init];
    if (self) {
        self.delegate = del;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - Get Products
- (void)getProducts {
    self.ProductsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:kProductIDs];
    self.ProductsRequest.delegate = self;
    [self.ProductsRequest start];
}

#pragma mark - Restore Purchases
- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Buy a Product
- (void)purchaseProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - Receive Products back from Apple
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (response.products.count > 0) {
        [self.delegate satelliteStore:self didFetchProducts:response.products];
    }
    else {
        [self.delegate satelliteStore:self didFetchProducts:nil];
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
    [self.delegate satelliteStore:self didPurchaseProduct:wasSuccessful];
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
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}



@end
