//
//  SatelliteStore.h
//  Red
//
//  Created by Benjamin Gordon on 4/27/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kProductIDs [NSSet setWithObject:@"com.subvertllc.HackerNews.Pro"]

@class SatelliteStore;

// Delegate
@protocol SatelliteStoreDelegate <NSObject>
@optional

- (void)satelliteStore:(SatelliteStore *)store didFetchProducts:(NSArray *)products;
- (void)satelliteStore:(SatelliteStore *)store didPurchaseProduct:(BOOL)success;

@end

// Class
@interface SatelliteStore : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (weak) id<SatelliteStoreDelegate> delegate;
@property (nonatomic, strong) SKProductsRequest *ProductsRequest;

- (instancetype)initWithDelegate:(id)del;
- (void)getProducts;
- (void)purchaseProduct:(SKProduct *)product;
- (void)restorePurchases;


@end
