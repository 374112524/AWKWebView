//
//  WKWebView+cookie.m
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/23.
//  Copyright © 2020 W. All rights reserved.
//

#import "WKWebView+cookie.h"

@implementation WKWebView (cookie)

-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain{
    
    NSString *cookieValue = [NSString stringWithFormat:@"document.cookie = '%@=%@;path=%@;domain=%@';", name,value,path,domain];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookieValue injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.configuration.userContentController addUserScript:cookieScript];
    
}

-(void)syncResponseCookie:(WKNavigationResponse *)navigationResponse{
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStroe = self.configuration.websiteDataStore.httpCookieStore;
        [cookieStroe getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }];
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

@end
