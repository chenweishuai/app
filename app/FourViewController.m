//
//  FourViewController.m
//  app
//
//  Created by Ibokan on 12-10-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FourViewController.h"
#import "GDataXMLNode.h"
#import "articleDetailViewController.h"
#import "ChannelViewController.h"


@interface FourViewController()

- (void)sendRequset:(NSString *)urlString;
- (void)getSourceData;

@end

@implementation FourViewController
@synthesize table;

@synthesize sourceData,articleDic,channelNameArr,channelIdArr;


- (void)dealloc 
{
    self.channelNameArr = nil;
    self.channelIdArr = nil;
    self.sourceData = nil;
    self.articleDic = nil;

    [table release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //自定义navigationbar和navigationitem
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 50);
    [btn setBackgroundImage:[UIImage imageNamed:@"setting-form-back-button.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *bakItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.backBarButtonItem = bakItem;
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(ddd)];
//    [backItem setBackButtonBackgroundImage:[UIImage imageNamed:@"setting-form-back-button.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [backItem setBackButtonBackgroundImage:[UIImage imageNamed:@"setting-form-back-button-click.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    backItem.width = 10;

    //self.navigationItem.backBarButtonItem = backItem;
//    [backItem release];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self sendRequset:@"http://mobileinterface.zhaopin.com/iphone/article/channellist.service"];
    
}


#pragma mark 私有方法

- (void)sendRequset:(NSString *)urlString   //建立异步连接
{
    NSURL *url = [[NSURL alloc]initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getSourceData   //初始化取得的数据 当数据接收完后调用
{
    self.articleDic = [[NSMutableDictionary alloc]init];
    self.channelNameArr = [[NSMutableArray alloc]init];
    self.channelIdArr = [[NSMutableArray alloc]init];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc]initWithData:self.sourceData options:0 error:nil];
    GDataXMLElement *root = [document rootElement];
    NSArray *childs = [root children];
    
    for (int i = 0; i < [childs count]; i++) {  //遍历每个栏目
        
        GDataXMLElement *element = [childs objectAtIndex:i];
        
        NSString *name = [[[element nodesForXPath:@"name" error:nil]objectAtIndex:0]stringValue];  //取得栏目名
        [self.channelNameArr addObject:name];
        
        NSString *cid = [[element attributeForName:@"id"]stringValue];  //取得栏目id
        [self.channelIdArr addObject:cid];
        
        
        NSMutableArray *articles = [[NSMutableArray alloc]init]; //取得栏目下的前五篇文章id和标题 然后存入字典
        
        NSArray *article = [element nodesForXPath:@"articles/article" error:nil];
        
        for(GDataXMLElement *tempElement in article)
        {
            NSMutableArray *tempArr = [[NSMutableArray alloc]init];
            [tempArr addObject:[[[tempElement children]objectAtIndex:0]stringValue]];
            [tempArr addObject:[[[tempElement children]objectAtIndex:1]stringValue]];
            [articles addObject:tempArr];
            [tempArr release];
        }
        
        [articleDic setObject:articles forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    NSLog(@"%d",[articleDic count]);
//    NSLog(@"%d",[channelIdArr count]);
//    NSLog(@"%d",[channelNameArr count]);
    [self.articleDic release];
    [self.channelNameArr release];
    [self.channelIdArr release];
    
    [self.table reloadData]; //让tableview重新加载数据
}

#pragma mark  异步代理

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response //当收到回应
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    //NSLog(@"%@",[res allHeaderFields]);
    self.sourceData = [[NSMutableData alloc]init];
    [self.sourceData release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  //当开始接收数据
{
    [self.sourceData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection  //结束接收数据  初始化数据
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //NSString *sourceString = [[NSString alloc]initWithData:self.sourceData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",sourceString);
    [self getSourceData];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error   //请求错误
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    //NSLog(@"%@",[error localizedDescription]);
}




#pragma mark talbeView的代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  //section的个数
{
    //NSLog(@"%d",[self.channelNameArr count]);
    return [self.channelNameArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //row的个数
{
    NSMutableArray *articles = [self.articleDic objectForKey:[NSString stringWithFormat:@"%d",section]];
    //NSLog(@"%d",[articles count]);
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  //cell的内容
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"accessoryArrow.png"]]];
    }
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"article"];
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:12];
    NSMutableArray *articles = [self.articleDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]];
    NSMutableArray *article = [articles objectAtIndex:indexPath.row];
    cell.textLabel.text = [article objectAtIndex:1];
    
    return cell; 
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  //cell的顶部试图
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    view.backgroundColor = [UIColor clearColor]; 
    
    //左边的label
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10,150, 30)];  
    
    label.backgroundColor = [UIColor clearColor];
    label.text = [self.channelNameArr objectAtIndex:section];
    
    [view addSubview:label];
    [label release];
    
    //右边的button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(250, 10, 50, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"moreNormal.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"moreSelected.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button setTitle:@"更多" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];

    button.tag = section;
    button.titleLabel.font = [UIFont fontWithName:@"Arial" size:13];
    [button addTarget:self action:@selector(pushToChannel:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    
    return [view autorelease];
} 

- (void)pushToChannel:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *btn = (UIButton *)sender;
        [self performSegueWithIdentifier:@"channel" sender:[NSString stringWithFormat:@"%d",btn.tag]];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath //当选中cell
{
    [self performSegueWithIdentifier:@"articleDetaile" sender:nil];    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  //即将推到下个viewController
{
    if ([segue.identifier isEqualToString:@"articleDetaile"]) {
        
        if ([segue.destinationViewController isKindOfClass:[articleDetailViewController class]]) {
            
            articleDetailViewController *article = (articleDetailViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [self.table indexPathForSelectedRow];  //得到选中的indexPath
            NSArray *arr = [[self.articleDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]]objectAtIndex:indexPath.row];
            article.articleId = [arr objectAtIndex:0];
        }
    
    } else if([segue.identifier isEqualToString:@"channel"])
    {
        if ([segue.destinationViewController isKindOfClass:[ChannelViewController class]]) {
            
            ChannelViewController *channel = (ChannelViewController *)segue.destinationViewController;
            
            if ([sender isKindOfClass:[NSString class]]) {
                
                channel.channelId = [self.channelIdArr objectAtIndex:[sender intValue]];
                channel.channelName = [self.channelNameArr objectAtIndex:[sender intValue]];
            }
        }
    }
}



- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
