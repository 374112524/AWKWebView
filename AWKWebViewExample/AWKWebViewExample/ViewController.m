//
//  ViewController.m
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/23.
//  Copyright © 2020 W. All rights reserved.
//

#import "ViewController.h"
#import "WKWebView+cookie.h"


@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    WKWebView * webview = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64-49)];
    [self.view addSubview:webview];
    webview.UIDelegate = self;
    webview.navigationDelegate = self;
    
    [webview addCookieName:@"cookieKey" value:@"value" path:@"/" domain:@"domain.com"];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://baidu.com"]]];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [webView syncResponseCookie:navigationResponse];
    decisionHandler(WKNavigationResponsePolicyAllow);
}


@end
