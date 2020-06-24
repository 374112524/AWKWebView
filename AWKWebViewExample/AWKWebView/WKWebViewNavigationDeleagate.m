//
//  WKWebViewNavigationDeleagate.m
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/24.
//  Copyright © 2020 W. All rights reserved.
//

#import "WKWebViewNavigationDeleagate.h"
#import "WKWebView+cookie.h"

@implementation WKWebViewNavigationDeleagate

-(BOOL)respondsToSelector:(SEL)aSelector{
    if ([NSStringFromSelector(aSelector) isEqualToString:NSStringFromSelector(@selector(webView:decidePolicyForNavigationResponse:decisionHandler:))]) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    if ([self.target respondsToSelector:aSelector]) {
        return self.target;
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [self.webView syncResponseCookie:navigationResponse];
    if ([self.target respondsToSelector:(@selector(webView:decidePolicyForNavigationResponse:decisionHandler:))]) {
        [self.target webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}
@end
