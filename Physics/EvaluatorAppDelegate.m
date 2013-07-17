//
//  EvaluatorAppDelegate.m
//  Evaluator
//
//  Created by Joseph caxton-Idowu on 15/09/2010.
//  Copyright caxtonidowu 2010. All rights reserved.
//


#import "EvaluatorAppDelegate.h"


// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static NSString* const kAnalyticsAccountId = @"UA-33965101-1";

@implementation EvaluatorAppDelegate

@synthesize window;
@synthesize	tabBarController,splashView;
@synthesize AllocatedMarks,Difficulty,Topic,TypeOfQuestion,DomainName,NumberOfQuestions,NumberOfQuestionsDisplayed,PossibleScores,ClientScores,buyScreen,SecondThread,m_facebook,FinishTestNow;

#pragma mark -
#pragma mark Application lifecycle
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    //Remove the my admin tabbarItem ..
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
    [viewControllers removeObjectAtIndex:5];
    [viewControllers removeObjectAtIndex:2];
    [tabBarController setViewControllers:viewControllers];

    DomainName = @"http://learnerscloud.com";
    //Copy database over if the database is not there on the device.Test
	
	[self CopyDataBase];
	SecondThread = nil;
	// Override point for customization after application launch.
	NSManagedObjectContext *context =[self managedObjectContext];
	
	if (!context) {
		
		UIAlertView *ContextError = [[UIAlertView alloc] initWithTitle: @"Cannot create context" 
									message: @"Error creating a connction to database" delegate: self 
													cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
		
		
		[ContextError show];
	
		
		
		return NO;
	}
	
	
	AllocatedMarks = [NSNumber numberWithInt:1];
	NSString *difficulty =(NSString *)@"Easy";
	[self setDifficulty:difficulty];
	
	NSString *Top = [[NSString alloc] initWithFormat:@"All"];
	self.Topic = Top;
	
	
	NSString *TOQ = [[NSString alloc] initWithFormat:@"All"];
	self.TypeOfQuestion = TOQ;

	
	NumberOfQuestions = [NSNumber numberWithInteger:10];
	NumberOfQuestionsDisplayed = [NSNumber numberWithInt: 0];
	PossibleScores =[NSNumber numberWithInt: 0];
	ClientScores = [NSNumber numberWithInt: 0];
     FinishTestNow = NO;
	
	//Track tourches on TabBar
	//UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touched)];
	//gr.minimumPressDuration = 0.0f;
	//gr.cancelsTouchesInView = NO;
	
	//[tabBarController.view addGestureRecognizer:gr];
	//[gr release];
	//Add to Window.
	
	
    //[window addSubview: tabBarController.view];
    [window setRootViewController:tabBarController];
	[window makeKeyAndVisible];
	
	//[self AddSplashScreen];
	//[self performSelector:@selector(Removesplash) withObject:nil afterDelay:1.5];
	
	//Setup User Defaults
	NSString *Soundkey = @"PlaySound";
	NSString *PlaySound = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:Soundkey];
	
	if (PlaySound == nil) {
		
		NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", Soundkey, nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	}
	
	// Setup ShowAnswer
	
	NSString *ShowAnswer =@"ShowMyAnswers";
	NSString *ShowMyAnswers = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:ShowAnswer];
	
	if (ShowMyAnswers == nil) {
		
		NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", ShowAnswer, nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	//User Access Level. 
	// Note : 1 = 30 Questions (Free) , 2 = 250 Questions, 3 = 500 Questions, 4 = 750 Questions, 5 = 1040 Questions
	
	NSString *AccessLevel =@"AccessLevel";
	NSString *MyAccessLevel = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:AccessLevel];
	//[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"]; //For testing only
	//[[NSUserDefaults standardUserDefaults] synchronize];
	if (MyAccessLevel == nil || [MyAccessLevel intValue] == 2) {
		
		[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"AccessLevel"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    if ([MyAccessLevel intValue] > 2) {
		
		[[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"AccessLevel"];
		[[NSUserDefaults standardUserDefaults] synchronize];	}

	
	// apple store transaction observer
	//CustomStoreObserver *observer = [[CustomStoreObserver alloc] init];
	//[[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
	//[observer release];
	
	// This is used for working around multi threaded problem on tabBar
	
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	[def setValue:@"" forKey:@"activeTab"];
	
	//[self removeBuyTabIfNotNeededFromTabController:[self tabBarController]];
    
    
    // Notification Service Registration
    
    NSLog(@"Registering for push notifications...");    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	// Reset Badge Count 
    application.applicationIconBadgeNumber = 0; 
    
    //Analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error;
    
    /* if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
     name:@"iOS1"
     value:@"iv1"
     withError:&error]) {
     NSLog(@"error in setCustomVariableAtIndex");
     } */
    
    if (![[GANTracker sharedTracker] trackEvent:@"Physics iPad Started"
                                         action:@"Launch iOS"
                                          label:@"Launch iOS"
                                          value:1
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
    
    if (![[GANTracker sharedTracker] trackPageview:@"/AppDelegate"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }
    

    // Review
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *ReviewID = [prefs stringForKey:@"Review"];
    if (ReviewID == nil) {
        
        NSString *ID = @"0";
        [prefs setObject:ID forKey:@"Review"];
        [prefs setObject:ID forKey:@"IHaveLeftReview"];
        
        [prefs synchronize];
        
    }
    //for testing
    /*NSString *ID = @"0";
     [prefs setObject:ID forKey:@"Review"];
     [prefs setObject:ID forKey:@"IHaveLeftReview"];
     
     [prefs synchronize];*/

	
	return YES;
}

- (void)PlaySound:(NSString *)FileName{

	NSString *audioPath = [[NSBundle mainBundle] pathForResource:FileName ofType:@"aiff"];
	NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
	SystemSoundID soundId;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioURL, &soundId);
	AudioServicesPlaySystemSound(soundId);

}



- (void) touched {
	
	
	//UIActivityIndicatorView *Activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(160,200,20,20)];
	//	Activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	//	Activity.hidesWhenStopped = YES;
	//	[Activity startAnimating];
	//	[self.tabBarController.view addSubview:Activity];
	//	[Activity release];
	
	
	
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}





/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            UIAlertView *ContextError = [[UIAlertView alloc] initWithTitle: @"Terminating" 
																   message: @"Application terminating for unknown reason contact support " delegate: self 
														 cancelButtonTitle: @"Ok" otherButtonTitles: nil];
			
			
			
			[ContextError show];
			
			
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
        } 
    }
	
}
#pragma mark -
#pragma mark Maintaince routine

-(BOOL)CopyDataBase{
	
	NSString *BundlePath, *DevicePath,*ResultsXMLDestination,*DescriptiveAnswersXMLDestination,*ResultsXML,*DescriptiveAnswersXML;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    DevicePath = [documentsDir stringByAppendingPathComponent:@"Physics.sqlite"];
	ResultsXMLDestination = [documentsDir stringByAppendingPathComponent:@"Results.xml"];
	DescriptiveAnswersXMLDestination = [documentsDir stringByAppendingPathComponent:@"DescriptiveAnswers.xml"];
	
    BundlePath = [[NSBundle mainBundle] pathForResource:@"Physics" ofType:@"sqlite"];
	ResultsXML = [[NSBundle mainBundle] pathForResource:@"Results" ofType:@"xml"];
	DescriptiveAnswersXML = [[NSBundle mainBundle] pathForResource:@"DescriptiveAnswers" ofType:@"xml"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error=[[NSError alloc]init]; 
	
	BOOL success=[fileManager fileExistsAtPath:DevicePath];
	// if the database does not exist on the phone copy database,DescriptiveAnswer.xml and Results.xml to phone
	if(!success)
	{
		[fileManager copyItemAtPath:ResultsXML toPath:ResultsXMLDestination error:&error];
		[fileManager copyItemAtPath:DescriptiveAnswersXML toPath:DescriptiveAnswersXMLDestination error:&error];
		
		success=[fileManager copyItemAtPath:BundlePath toPath:DevicePath error:&error];
		
		if(!success){
			
			NSAssert1(0,@"failed to create database with message '%@'.",[error localizedDescription]); 
		}
	}
	
	
	else
	{
		sqlite3 *Database;
		NSInteger DeviceVersionNumber=0;
		
		sqlite3_stmt *CompiledStatement=nil;
		
		//check version number on client phone
		if(sqlite3_open([DevicePath UTF8String],&Database) == SQLITE_OK)
		{
			sqlite3_prepare_v2(Database, "SELECT ZVersionNumber FROM ZDBVersion", -1, &CompiledStatement, NULL);
			while(sqlite3_step(CompiledStatement) == SQLITE_ROW)
			{
				DeviceVersionNumber=sqlite3_column_int(CompiledStatement,0);
			}
			sqlite3_reset(CompiledStatement);
			sqlite3_finalize(CompiledStatement);
			sqlite3_close(Database);
		}
		
		//check version Number on Bundle DataBase
		sqlite3 *Database1;
		NSInteger BundleVersionNumber = 0;
		
		sqlite3_stmt *CompiledStatement1=nil;
		
		if(sqlite3_open([BundlePath UTF8String],&Database1) == SQLITE_OK)
		{
			sqlite3_prepare_v2(Database1, "SELECT ZVersionNumber FROM ZDBVersion", -1, &CompiledStatement1, NULL);
			while(sqlite3_step(CompiledStatement1) == SQLITE_ROW)
			{
				BundleVersionNumber=sqlite3_column_int(CompiledStatement1,0);
			}
			sqlite3_reset(CompiledStatement1);
			sqlite3_finalize(CompiledStatement1);
			sqlite3_close(Database1);
		}
		
		// if the version on bundle is greater than the version on device then send a new copy ofthe database, but remove the existing file first.
		
		if (BundleVersionNumber > DeviceVersionNumber ) {
			
			
			[fileManager removeItemAtPath:DevicePath error:&error];
			
			BOOL success = [fileManager copyItemAtPath:BundlePath toPath:DevicePath error:&error];
			
			if(!success){
				
				NSAssert1(0,@"failed to create database with message '%@'.",[error localizedDescription]); 
			}
		}
		
		//NSLog(@"Bundle Version Number is %i ---  Client Version Number is %i",BundleVersionNumber,DeviceVersionNumber);
		
	}


	
	///Stopped here;

	
	
	
	
	return YES;
}

-(BOOL)isDeviceConnectedToInternet{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    BOOL internetActive = NO;
    switch (networkStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            
            internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            
            internetActive = YES;
            
            break;
        }
            
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            
            internetActive = YES;
            
            break;
        }
    }
    return internetActive;
    
    
}



#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
		
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Evaluator" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Physics.sqlite"]];
	
	/* Turn on automatic store migration
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	Turn on automatic migration */
	
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
	
		
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
		
		UIAlertView *CoordinatorError = [[UIAlertView alloc] initWithTitle: @"Cannot connect to Database" 
															   message: @"Persistent store not contactable or schema is incompatible" delegate: self 
													 cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		
		
		[CoordinatorError show];
		
		
		
		
		/*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }    
    
    return persistentStoreCoordinator;
}





#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
			//[[ImageCache sharedImageCache] removeAllImagesInMemory];
	
	
}

// Notification service

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
       
   // NSString *DeviceUDID = [NSString stringWithFormat:@"%@",[UIDevice currentDevice].uniqueIdentifier];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
    NSString *DeviceUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *DeviceTokenRemoveCh1 = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];

    NSString *DeviceToken = [DeviceTokenRemoveCh1 stringByReplacingOccurrencesOfString: @" " withString: @""];

    
    NSURLConnection *conn;
    NSString *queryString = [NSString stringWithFormat:@"http://www.learnerscloud.com/services/ios/deviceToken.asmx/Update?UDID=%@&deviceToken=%@" , DeviceUDID, DeviceToken ];
    NSURL *url = [NSURL URLWithString:queryString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        
    } 

    
        }
    
    
   /*  NSString *Username = [NSString stringWithFormat:@"r_keay@yahoo.com"];
    NSString *password = [NSString stringWithFormat:@"Iam6today"];
    
    //NSMutableData *webData;
   // NSMutableString *soapResults;
    NSURLConnection *conn;
    
    // Practive code for calling web service
    
    NSString *queryString = [NSString stringWithFormat:@"http://stage.learnerscloud.com/services/ios/authentication.asmx/GetCurrentPackage?emailAddress=%@&password=%@" , Username, password ];
    
    NSURL *url = [NSURL URLWithString:queryString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:0 forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"GET"];
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        //webData = [[NSMutableData data] retain];
    } */
    
    

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
   
    // for testing only
    // NSString *content = [NSString stringWithUTF8String:[data bytes]];
    
   // NSLog(@"%@",content);

    
    
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@",str);    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }    
    
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [m_facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [m_facebook handleOpenURL:url]; 
}








@end

