//
//  InAppPurchaseManager.m
//  M-Safety
//
//  Created by Osellus on 12-04-05.
//  Copyright (c) 2012 osellus. All rights reserved.
//

#import "InAppPurchaseManager.h"

@interface InAppPurchaseManager ()
{    
    BOOL loaded;
    NSArray *productsArray;
}

-(void) completeTransaction:(SKPaymentTransaction *)transaction;
-(void) failedTransaction:(SKPaymentTransaction *)transaction;
-(void) restoredTransaction:(SKPaymentTransaction *)transaction;

@end

@implementation InAppPurchaseManager

+(InAppPurchaseManager *)sharedManager {
    
    static InAppPurchaseManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[InAppPurchaseManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init {
    self = [super init];
    if (self) {
        loaded = NO;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

#pragma mark -

-(void)loadProductsWithIds:(NSMutableArray*)productIds {
    
    if (loaded)
        return;
    
    /*
    NSMutableArray *identifiersArray = [NSMutableArray arrayWithCapacity:0];
    
    for (Module *module in modulesArray)
        [identifiersArray addObject:[InAppPurchaseManager identifierForModule:module]];
    */
    
    NSSet *identifiersSet = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiersSet];
    request.delegate = self;
    [request start];
}

-(void)purchaseProductWithIdentifier:(NSString *)identifier
{
    SKProduct *product = nil;
    for (SKProduct *_product in productsArray)
        if ([_product.productIdentifier isEqualToString:identifier]) {
            product = _product;
            break;
        }
    
    if (!product)
        return;
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)recordTransaction:(SKPaymentTransaction *)transaction {
    
}

-(void)applyPurchasedProductWithIdentifier:(NSString *)identifier error:(NSError*)error
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithString:identifier] forKey:@"identifier"];
    if(error)
        [dictionary setObject:error forKey:@"error"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PURCHASE object:self userInfo:dictionary];
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"%s", __func__);
    
    [productsArray release];
    productsArray = [[NSArray alloc] initWithArray:response.products];
    
    loaded = YES;
    
    [request autorelease];
}

#pragma mark - SKTransactionObserver

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    NSLog(@"%s", __func__);
    
    for (SKPaymentTransaction *_transaction in transactions)
    {
        switch (_transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased: [self completeTransaction:_transaction];
                break;
            case SKPaymentTransactionStateFailed: [self failedTransaction:_transaction];
                break;
            case SKPaymentTransactionStateRestored: [self restoredTransaction:_transaction];
                break;
            default: break;
        }
    }
}

-(void) completeTransaction:(SKPaymentTransaction *)transaction {
    
    [self recordTransaction: transaction];
    [self applyPurchasedProductWithIdentifier: transaction.payment.productIdentifier error:nil];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) restoredTransaction:(SKPaymentTransaction *)transaction {
    
    [self recordTransaction: transaction];
    [self applyPurchasedProductWithIdentifier: transaction.payment.productIdentifier error:nil];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void) failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"%s", __func__);
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"%s %@", __func__, transaction.error);
        
       
    }
    
     [self applyPurchasedProductWithIdentifier: transaction.payment.productIdentifier error:transaction.error];
   // [self applyPurchasedProductWithIdentifier: transaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    NSLog(@"%s", __func__);
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"%s %@", __func__, error);
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"%s", __func__);
}

@end
