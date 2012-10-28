//
//  TrueOrFalseYesOrNo.h
//  Evaluator
//
//  Created by Joseph caxton-Idowu on 27/10/2010.
//  Copyright 2010 caxtonidowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lk_QuestionTemplate.h"
#import "Topics.h"
#import "QuestionItems.h"
#import "EvaluatorAppDelegate.h"
#import "CheckExistingFiles.h"
#import <MessageUI/MessageUI.h>
#import "WebViewInCell.h"

@interface TrueOrFalseYesOrNo : UIViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate>{
	
	lk_QuestionTemplate *QuestionTemplate;
	Topics  *SelectedTopic;
	
	//Question Header
	//UIWebView *QuestionHeaderBox;
	
	NSArray *fileList;
	
	
	NSString *DirLocation; // Location of Dir
	NSString *SFileName; // Short file name
	
	
	//NSString *DirLocation_Edit; // Location of Dir for edit
	NSString *SFileName_Edit; // Short file name for edit
	QuestionItems	*QItem_Edit;
	QuestionItems	*QItem_View;
	
	UITableView *FileListTable;
	
	NSMutableArray *AnswerObjects;
	
	NSArray *AnswerControls;
	
	UILabel *True;
	UILabel *False;
	BOOL ShowAnswer;
   
	UIBarButtonItem *Continue;

}
@property (nonatomic, retain) lk_QuestionTemplate *QuestionTemplate;
@property (nonatomic, retain) Topics  *SelectedTopic;

//@property (nonatomic, retain) UIWebView *QuestionHeaderBox;
@property (nonatomic, retain) NSArray *fileList;
@property (nonatomic, retain)  UITableView *FileListTable;


@property (nonatomic, retain) NSString *DirLocation;
@property (nonatomic, retain) NSString *SFileName;


//@property (nonatomic, retain) NSString *DirLocation_Edit;
@property (nonatomic, retain) NSString *SFileName_Edit;
@property (nonatomic, retain) QuestionItems	*QItem_Edit;
@property (nonatomic, retain) QuestionItems	*QItem_View;

@property (nonatomic, retain) NSMutableArray *AnswerObjects;
@property (nonatomic, retain) NSArray *AnswerControls;

@property (nonatomic, retain) UILabel		*True;
@property (nonatomic, retain) UILabel		*False;
@property (nonatomic, assign) BOOL ShowAnswer;
@property (nonatomic, retain) UIBarButtonItem *Continue;


-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView;
-(IBAction)ContinueToNextQuestion:(id)sender;
- (void)configureCell:(WebViewInCell *)mycell HTMLStr:(NSString *)value;

@end
