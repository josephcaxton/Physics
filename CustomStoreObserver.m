//
//  CustomStoreObserver.m
//  EvaluatorForIPad
//
//  Created by Joseph caxton-Idowu on 20/02/2011.
//  Copyright 2011 caxtonidowu. All rights reserved.
//

#import "CustomStoreObserver.h"


@implementation CustomStoreObserver


- (id) init

{
	
	if(self = [super init])
		
	{
		
		[ [SKPaymentQueue defaultQueue] addTransactionObserver: self];
		
	}
	
	return self;
	
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	EvaluatorAppDelegate *appDelegate = (EvaluatorAppDelegate *)[UIApplication sharedApplication].delegate;
	
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				[appDelegate.buyScreen viewWillAppear:YES];
				[(UIActivityIndicatorView *)[appDelegate.buyScreen navigationItem].rightBarButtonItem.customView stopAnimating];
				
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				[appDelegate.buyScreen viewWillAppear:YES];
				[(UIActivityIndicatorView *)[appDelegate.buyScreen navigationItem].rightBarButtonItem.customView stopAnimating];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
				[appDelegate.buyScreen viewWillAppear:YES];
				[(UIActivityIndicatorView *)[appDelegate.buyScreen navigationItem].rightBarButtonItem.customView stopAnimating];
				break;
			default:
				break;
		}
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		UIAlertView *PaymentError = [[UIAlertView alloc] initWithTitle: @"Error On Payment" 
															message: @"There has been an error completing your payment transaction, please try again" delegate: self 
												  cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		
		
		[PaymentError show];
		
		
		
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	// [self recordTransaction: transaction];
	
	//Provide the new content
	 [self provideContent: transaction.originalTransaction.payment.productIdentifier];
	
	//Finish the transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	//If you want to save the transaction
	// [self recordTransaction: transaction];
	
	//Provide the new content
	[self provideContent: transaction.payment.productIdentifier];
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
}

-(void) provideContent:(NSString *)productIdentifier{
	
	// From Free
	if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.250"]) {
		
		[[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"AccessLevel"];
	
	}
		 
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.500"])
		 
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"AccessLevel"];	 
			 
			 
	}
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.750"])
		
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:@"AccessLevel"];	 
		
		
	}
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.1000"])   
		
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"];	 
		
		
	}
   	// From 250
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.250To500"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"AccessLevel"];
		
	}
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.250To750"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:@"AccessLevel"];
		
	}
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.250To1000"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"];
		
	}
    
	// From 500
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.500To750"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:@"AccessLevel"];
		
	}
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.500To1000"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"];
		
	}
    
	
	
	
	// From 750
	
	else if ([productIdentifier isEqualToString:@"com.LearnersCloud.iEvaluatorForiPad.Physics.750To1000"])
	{
		
		[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"];
		
	}
   

    
    
    
        
    	
	
			
						
			
			
}
	
- (void) dealloc

{
	
	[ [SKPaymentQueue defaultQueue] removeTransactionObserver: self];
	
	
	
}

@end
