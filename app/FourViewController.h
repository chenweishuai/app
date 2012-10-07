//
//  FourViewController.h
//  app
//
//  Created by Ibokan on 12-10-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FourViewController : UIViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSMutableData *sourceData;   //接收到的数据
@property(nonatomic,retain)NSMutableArray *channelNameArr,*channelIdArr;  //栏目名  栏目id
@property(nonatomic,retain)NSMutableDictionary *articleDic;  //存放文章的id和title key是所在的栏目下标
@property (retain, nonatomic) IBOutlet UITableView *table;

@end
