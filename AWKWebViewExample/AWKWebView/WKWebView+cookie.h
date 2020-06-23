//
//  WKWebView+cookie.h
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/23.
//  Copyright © 2020 W. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (cookie)

-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain;

-(void)syncResponseCookie:(WKNavigationResponse *)navigationResponse;

@end

NS_ASSUME_NONNULL_END
