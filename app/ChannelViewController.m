//
//  ChannelViewController.m
//  app
//
//  Created by Ibokan on 12-10-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChannelViewController.h"
#import "GDataXMLNode.h"
#import "articleDetailViewController.h"

@interface ChannelViewController()

- (void)sendRequset;
- (void)getSourceData ;

@end

@implementation ChannelViewController
@synthesize table;
@synthesize channelId,channelName,sourceData;
@synthesize articleIdAndTitle;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    table.delegate = self;
    table.dataSource = self;
    self.navigationItem.title = self.channelName;
    [self sendRequset];
}

#pragma mark 私有方法

- (void)sendRequset   //建立异步连接
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://mobileinterface.zhaopin.com/iphone/article/articlelist.service?cid=%@",self.channelId]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getSourceData  //初始化取得的数据 当数据接收完后调用
{
    self.articleIdAndTitle = [[NSMutableDictionary alloc]init];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc]initWithData:self.sourceData options:0 error:nil];
    GDataXMLElement *root = [document rootElement];
    
    NSArray *article = [root nodesForXPath:@"//article" error:nil];
    for (int i = 0; i < [article count]; i++) {
        
        NSMutableArray *idAndTitle = [[NSMutableArray alloc]init];
        [idAndTitle addObject:[[[[article objectAtIndex:i] nodesForXPath:@"id" error:nil]objectAtIndex:0]stringValue]];
        [idAndTitle addObject:[[[[article objectAtIndex:i] nodesForXPath:@"title" error:nil]objectAtIndex:0]stringValue]];
        [self.articleIdAndTitle setObject:idAndTitle forKey:[NSString stringWithFormat:@"%d",i]];
        [idAndTitle release];
    }
    
    [self.articleIdAndTitle release];
    [self.table reloadData];
}

#pragma mark  异步代理

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response //当收到回应
{
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
    [self getSourceData];  //取得数据
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error   //请求错误
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma table的代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //row的个数
{
    return [self.articleIdAndTitle count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  //section的个数
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  //设置cell的内容
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"accessoryArrow.png"]]];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:12];
    cell.textLabel.text = [[self.articleIdAndTitle objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]objectAtIndex:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath //当选中cell
{
    [self performSegueWithIdentifier:@"articleDetaile" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"articleDetaile"]) {
        
        if ([segue.destinationViewController isKindOfClass:[articleDetailViewController class]]) {
            
            articleDetailViewController *articled = (articleDetailViewController *)segue.destinationViewController;
            NSIndexPath *indexPath = [table indexPathForSelectedRow];
            articled.articleId = [[self.articleIdAndTitle objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]objectAtIndex:0];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    
    self.articleIdAndTitle = nil;
    self.sourceData = nil;
    self.channelName = nil;
    self.channelId = nil;
    [table release];
    [super dealloc];
}
@end
