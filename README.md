# AWKWebView
wkwebview cookie注入与同步

支持 pod 'AWKWebView' 导入

包含功能：

1.同步网页下发的cookie
不需要调用任何代码即可实现wkwebview网页下发的cookie自动同步到本地HttpCookieStorage中，解决H5cookie种不上/取不到的问题。

2.手动注入cookie
引入分类头文件，通过wkwebview addCookie:方法手动设置cookie到网页。
