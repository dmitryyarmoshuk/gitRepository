//
//  InAppPurchaseManager.h
//  M-Safety
//
//  Created by Osellus on 12-04-05.
//  Copyright (c) 2012 osellus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define NOTIFICATION_PURCHASE @"NOTIFICATION_PURCHASE"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    
}

+(InAppPurchaseManager *)sharedManager;
-(void)loadProductsWithIds:(NSMutableArray*)productIds;
-(void)purchaseProductWithIdentifier:(NSString *)identifier;

@end
