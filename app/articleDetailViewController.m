//
//  articleDetailViewController.m
//  app
//
//  Created by Ibokan on 12-10-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "articleDetailViewController.h"
#import "GDataXMLNode.h"


@interface articleDetailViewController()

- (void)sendRequset;  //发送请求
- (void)getSourceData;  //取得数据

@end


@implementation articleDetailViewController
@synthesize articleTitle;
@synthesize articleDate;
@synthesize articleContent;
@synthesize sourceData;
@synthesize articleId;




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
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sendRequset];   //建立异步连接
}

#pragma mark 私有方法

- (void)sendRequset   //建立异步连接
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://mobileinterface.zhaopin.com/iphone/article/articledetail.service?id=%@",self.articleId]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)getSourceData  //初始化取得的数据 当数据接收完后调用
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc]initWithData:self.sourceData options:0 error:nil];
    GDataXMLElement *root = [document rootElement];
    
    articleTitle.text = [[[root nodesForXPath:@"article/title" error:nil]objectAtIndex:0]stringValue];
    articleDate.text = [[[root nodesForXPath:@"article/startdate" error:nil]objectAtIndex:0]stringValue];
    articleContent.text = [[[root nodesForXPath:@"article/content" error:nil]objectAtIndex:0]stringValue];
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
    //NSLog(@"%@",[error localizedDescription]);
}


- (void)viewDidUnload
{
    [self setArticleTitle:nil];
    [self setArticleDate:nil];
    [self setArticleContent:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    
    self.sourceData = nil;
    self.articleId = nil;
    [articleTitle release];
    [articleDate release];
    [articleContent release];
    [super dealloc];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
