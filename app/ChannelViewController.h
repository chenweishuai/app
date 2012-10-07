//
//  ChannelViewController.h
//  app
//
//  Created by Ibokan on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *table;
@property(nonatomic,retain)NSString *channelId,*channelName;
@property(retain,nonatomic)NSMutableData *sourceData;
@property(nonatomic,retain)NSMutableDictionary *articleIdAndTitle;

@end
