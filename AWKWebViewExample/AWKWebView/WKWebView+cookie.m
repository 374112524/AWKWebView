//
//  WKWebView+cookie.m
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/23.
//  Copyright © 2020 W. All rights reserved.
//

#import "WKWebView+cookie.h"
#import <objc/runtime.h>
#import "WKWebViewNavigationDeleagate.h"

static char cookiesKey;
static char delegateKey;

@interface WKWebView ()

@property (nonatomic,strong)NSMutableArray * cookies;
@property (nonatomic,strong)WKWebViewNavigationDeleagate * delegate;

@end

@implementation WKWebView (cookie)

void _swizzleInstanceMethod(Class className, SEL original, SEL new) {
    Method originalMethod = class_getInstanceMethod(className, original);
    Method newMethod = class_getInstanceMethod(className, new);
    BOOL didAddMethod = class_addMethod(className, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(className, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _swizzleInstanceMethod(self, @selector(loadRequest:), @selector(cookie_loadRequest:));
        _swizzleInstanceMethod(self, @selector(setNavigationDelegate:), @selector(cookie_setNavigationDelegate:));
    });
}
-(void)addCookieName:(NSString *)name value:(NSString *)value domains:(NSArray <NSString *>*)domains{
    for (NSString * domain in domains) {
        [self addCookieName:name value:value path:@"/" domain:domain];
    }
}
-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain{
    [self addCookieName:name value:value path:path domain:domain toUserContent:self.configuration.userContentController];
}
-(void)addCookieName:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain toUserContent:(WKUserContentController *)userContentController{
    name = name?:@"";
    value = value?:@"";
    path = path?:@"/";
    domain = domain?:@"";
    NSString *cookieValue = [NSString stringWithFormat:@"'%@=%@;path=%@;domain=%@';", name,value,path,domain];
    if (!self.cookies) {
        self.cookies = [NSMutableArray array];
    }
    [self.cookies addObject:[cookieValue stringByReplacingOccurrencesOfString:@"'" withString:@""]];
    cookieValue = [NSString stringWithFormat:@"document.cookie = %@",cookieValue];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookieValue injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    
    for (NSHTTPCookie * cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        if ([cookie.name isEqualToString:name] && [cookie.value isEqualToString:value] && [cookie.domain isEqualToString:domain]) {
            return;
        }
    }
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:domain forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:path forKey:NSHTTPCookiePath];
    NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    NSLog(@"%@",[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies);
    
}
-(NSString *)getCustomCookies{
    return [self.cookies componentsJoinedByString:@""];
}
-(void)addCookieToRequest:(NSMutableURLRequest *)request Name:(NSString *)name value:(NSString *)value path:(NSString *)path domain:(NSString *)domain{
    NSString *cookieValue = [NSString stringWithFormat:@"'%@=%@;path=%@;domain=%@';", name,value,path,domain];
    [self addCookie:cookieValue toRequest:request];
}
-(void)addCookie:(NSString *)cookie toRequest:(NSMutableURLRequest *)request{
    [request setValue: cookie forHTTPHeaderField:@"Cookie"];
}
-(void)addCookieToRequest:(NSMutableURLRequest *)request{
    [self addCookie:[self getCustomCookies] toRequest:request];
}

-(WKNavigation *)cookie_loadRequest:(NSURLRequest *)request{
    NSMutableURLRequest * mutableRequest = request.mutableCopy;
    //同步本地cookie
//    [self syncRequestCookie:mutableRequest];
    NSString * headerCookies = [mutableRequest.allHTTPHeaderFields objectForKey:@"Cookie"];
    if (!headerCookies.length) {
        //本地没有cookie则使用手动设置的cookie
        [self addCookieToRequest:mutableRequest];
    }
    return [self cookie_loadRequest:mutableRequest];
}

//同步本地cookie到初次请求
- (void)syncRequestCookie:(NSMutableURLRequest *)request {
    if (!request.URL) {
        return;
    }
    NSArray *availableCookie = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
    if (availableCookie.count > 0) {
        NSDictionary *reqHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookie];
        NSString *cookieStr = [reqHeader objectForKey:@"Cookie"];
        [request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
}

//通过 JS 注入 NSHTTPCookieStorage->WKHTTPCookieStore
- (NSString *)ajaxCookieScripts {
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        // Create a line that appends this cookie to the web view's document's cookies
        [cookieScript appendFormat:@"document.cookie='%@=%@;", cookie.name, cookie.value];
        if (cookie.domain || cookie.domain.length > 0) {
            [cookieScript appendFormat:@"domain=%@;", cookie.domain];
        }
        if (cookie.path || cookie.path.length > 0) {
            [cookieScript appendFormat:@"path=%@;", cookie.path];
        }
        if (cookie.expiresDate) {
            [cookieScript appendFormat:@"expires=%@;", cookie.expiresDate];
        }
        if (cookie.secure) {
            [cookieScript appendString:@"Secure;"];
        }
        if (cookie.HTTPOnly) {
            [cookieScript appendString:@"HTTPOnly;"];
        }
        [cookieScript appendFormat:@"'\n"];
    }
    return cookieScript;
}

-(void)cookie_setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate{
    if (!self.delegate) {
        self.delegate = [[WKWebViewNavigationDeleagate alloc]init];
        self.delegate.target = navigationDelegate;
        self.delegate.webView = self;
    }
    [self cookie_setNavigationDelegate:self.delegate];
}
-(void)syncRequestCookie{
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: [self ajaxCookieScripts] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
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

- (NSMutableArray *)cookies{
    return objc_getAssociatedObject(self, &cookiesKey);
}
-(void)setCookies:(NSMutableArray *)cookies{
    objc_setAssociatedObject(self, &cookiesKey, cookies, OBJC_ASSOCIATION_RETAIN);
}
-(WKWebViewNavigationDeleagate *)delegate{
    return objc_getAssociatedObject(self, &delegateKey);
}
-(void)setDelegate:(WKWebViewNavigationDeleagate *)delegate{
    objc_setAssociatedObject(self, &delegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
}
@end
