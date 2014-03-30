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

@implementation SatellitePurchaseBlockObject

+(SatellitePurchaseBlockObject *)purchaseBlockObjectForProductIdentifier:(NSString *)productIdentifier withCompletion:(PurchaseProductCompletion)completionBlock{
    
    SatellitePurchaseBlockObject * blockObject = [[self alloc] init];
    
    blockObject.productIdentifier = productIdentifier;
    blockObject.completionBlock = completionBlock;
    
    return blockObject;
    
}

@end

@implementation SatelliteGetProductsBlockObject

-(id)initWithProductIdentifiers:(NSArray *)productIdentifiers{
    
    self = [super init];
    
    if(self){
        
        NSSet * productIdentifiersSet = [NSSet setWithArray:productIdentifiers];
        
        _productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiersSet];
        
    }
    return self;
}

+(SatelliteGetProductsBlockObject *)getBlockObjectForProductIdentifiers:(NSArray *)productIdentifiers withCompletion:(GetProductsCompletion)completionBlock{
    
    SatelliteGetProductsBlockObject * blockObject = [[SatelliteGetProductsBlockObject alloc] initWithProductIdentifiers:productIdentifiers];
    
    blockObject.productIdentifiers = productIdentifiers;
    blockObject.completionBlock = completionBlock;
    
    return blockObject;
    
}

@end

@interface SatelliteStore ()

@end

@implementation SatelliteStore

#pragma mark - Singleton Creation
+ (SatelliteStore *)shoppingCenter {
    
    static SatelliteStore * _shoppingCenter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shoppingCenter = [[self alloc] init];
    });
    
    return _shoppingCenter;
}

- (id)init {
	if (self = [super init]) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.Inventory = [NSMutableDictionary dictionary];
        self.purchaseCompletionBlockObjects = [NSMutableArray array];
        self.fetchProductsCompletionBlockObjects = [NSMutableArray array];
        
	}
	return self;
}

#pragma mark - Get Products

-(void)getProductWithIdentifier:(NSString *)productIdentifier withCompletion:(GetProductsCompletion)completion{
    
    SatelliteGetProductsBlockObject * blockObject = [SatelliteGetProductsBlockObject getBlockObjectForProductIdentifiers:@[productIdentifier] withCompletion:completion];
    
    blockObject.productRequest.delegate = self;
    
    [self.fetchProductsCompletionBlockObjects addObject:blockObject];
    
    [blockObject.productRequest start];
    
}

-(void)getProductsWithIdentifiers:(NSArray *)productIdentifiers withCompletion:(GetProductsCompletion)completion{
    
    SatelliteGetProductsBlockObject * blockObject = [SatelliteGetProductsBlockObject getBlockObjectForProductIdentifiers:productIdentifiers withCompletion:completion];
    
    blockObject.productRequest.delegate = self;
    
    [self.fetchProductsCompletionBlockObjects addObject:blockObject];
    
    [blockObject.productRequest start];
    
    
}
#pragma mark - Restore Purchases
- (void)restorePurchasesWithCompletion:(RestoreProductsCompletion)completion {
    
    _restoreProductsCompletion = completion;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

#pragma mark - Buy a Product
- (void)purchaseProduct:(SKProduct *)product withCompletionBlock:(PurchaseProductCompletion)completionBlock {
    
    SatellitePurchaseBlockObject * blockObject = [SatellitePurchaseBlockObject purchaseBlockObjectForProductIdentifier:product.productIdentifier withCompletion:completionBlock];
    
    NSPredicate * dulicatePredicate = [NSPredicate predicateWithFormat:@"SELF.productIdentifier = %@", blockObject.productIdentifier];
    
    if([[self.purchaseCompletionBlockObjects filteredArrayUsingPredicate:dulicatePredicate] count] == 0){
        
        [self.purchaseCompletionBlockObjects addObject:blockObject];
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        
    }else{
        
        NSLog(@"Satellite Store: That product identifier is already attempting to be purchased. You can not purchase the same item while waiting for the return block");
        
    }
    
    
    
}

- (void)purchaseProductWithIdentifier:(NSString *)identifier withCompletion:(PurchaseProductCompletion)completionBlock {
    
    
    [self getProductWithIdentifier:identifier withCompletion:^(BOOL success, NSArray *products, NSError * error) {
        
        if(success && products.count > 0){
            
            [self purchaseProduct:products.lastObject withCompletionBlock:completionBlock];
        }else{
            
            if(completionBlock){
                completionBlock(NO, nil, nil, error);
            }
            
        }
        
    }];
    
    
}

-(void)finishFetchProductBlockObject:(SatelliteGetProductsBlockObject*)blockObject withResponse:(SKProductsResponse *)response{
    
    if(blockObject.completionBlock){
        
        if(response.products.count > 0){
            
            blockObject.completionBlock(YES, response.products, nil);
            
        }else{
            
            NSError * noProductsError = [NSError errorWithDomain:@"SatelliteStore" code:-10 userInfo:@{@"description":@"No products were found matching the identifiers"}];
            
            blockObject.completionBlock(NO, nil, noProductsError);
            
        }
        
        
    }
    
    [self.fetchProductsCompletionBlockObjects removeObject:blockObject];
    
    
}

#pragma mark - Receive Products back from Apple
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for(SatelliteGetProductsBlockObject * blockObject in self.fetchProductsCompletionBlockObjects.copy){
        
        if([blockObject.productRequest isEqual:request]){
            
            [self finishFetchProductBlockObject:blockObject withResponse:response];
            
            
        }
        
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
            case SKPaymentTransactionStatePurchasing:
                break;
            default:
                break;
        }
    }
    
}
-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    
    if(_restoreProductsCompletion){
        
        _restoreProductsCompletion(nil, error);
        
    }
    
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    //If there is a restore block, add the transactions product ids that were restored to array and call the block
    if(_restoreProductsCompletion){
        
        NSMutableArray * productIdentifiers = [NSMutableArray array];
        
        for(SKPaymentTransaction * transaction in queue.transactions){
            
            if(transaction.transactionState == SKPaymentTransactionStateRestored){
                
                [productIdentifiers addObject:transaction.payment.productIdentifier];
                
            }
            
        }
        
        _restoreProductsCompletion(productIdentifiers, nil);
        
    }
    
}

#pragma mark - Payment Notifications
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //Get the product identifier
    NSString * productIdentifier = transaction.payment.productIdentifier;
    
    //Predicate for finding the block object that matched the product identifier
    NSPredicate * matchingProductIdentifier = [NSPredicate predicateWithFormat:@"SELF.productIdentifier = %@", productIdentifier];
    
    //Create the block object
    SatellitePurchaseBlockObject * blockObject = [self.purchaseCompletionBlockObjects filteredArrayUsingPredicate:matchingProductIdentifier].lastObject;
    
    //Send the block if there is a completionBlock
    if(blockObject.completionBlock){
        
        blockObject.completionBlock(wasSuccessful, productIdentifier, transaction, transaction.error);
        
        [self.purchaseCompletionBlockObjects removeObject:blockObject];
        
    }
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:NO];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:YES];
}
-(BOOL)isOpenForBusiness{
    return [SKPaymentQueue canMakePayments];
}

@end
