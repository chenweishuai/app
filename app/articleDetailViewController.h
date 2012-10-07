//
//  articleDetailViewController.h
//  app
//
//  Created by Ibokan on 12-10-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface articleDetailViewController : UIViewController

@property(assign,nonatomic)NSString *articleId;
@property(retain,nonatomic)NSMutableData *sourceData;
@property (retain, nonatomic) IBOutlet UILabel *articleTitle;
@property (retain, nonatomic) IBOutlet UILabel *articleDate;
@property (retain, nonatomic) IBOutlet UITextView *articleContent;


@end
