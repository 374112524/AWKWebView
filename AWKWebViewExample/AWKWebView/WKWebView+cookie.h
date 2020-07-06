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

/*! @abstract 手动将cookie注入到网页中 ,在loadRequest之前调用*/
-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain;
-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain toUserContent:(WKUserContentController *)userContentController;
/*! @abstract 多域名注入cookie*/
-(void)addCookieName:(NSString *)name value:(NSString *)value domains:(NSArray <NSString *>*)domains;
/*! @abstract 获取手动注入的cookies*/
-(NSString *)getCustomCookies;
/*! @abstract 手动将cookie注入到请求中 */
-(void)addCookieToRequest:(NSMutableURLRequest *)request Name:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain;
/*! @abstract 手动将cookie注入到请求中*/
-(void)addCookie:(NSString *)cookie toRequest:(NSMutableURLRequest *)request;
/*! @abstract 将addCookieName注入的cookie同步到请求中*/
-(void)addCookieToRequest:(NSMutableURLRequest *)request;

/*! @abstract 解决网页写入本地的cookie在网页中访问不到的问题，将返回的cookie同步到NSHTTPCookieStorage中 */
-(void)syncResponseCookie:(WKNavigationResponse *)navigationResponse;

@end

NS_ASSUME_NONNULL_END
