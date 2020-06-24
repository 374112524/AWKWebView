//
//  WKWebViewNavigationDeleagate.h
//  AWKWebViewExample
//
//  Created by 王纯志 on 2020/6/24.
//  Copyright © 2020 W. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewNavigationDeleagate : NSObject<WKNavigationDelegate>

@property (nonatomic ,weak) id<WKNavigationDelegate> target;
@property (nonatomic ,weak) WKWebView * webView;

@end

NS_ASSUME_NONNULL_END
