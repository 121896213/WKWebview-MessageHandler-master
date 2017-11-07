//
//  TestViewController.m
//  WKWebViewMessageHandlerDemo
//
//  Created by 小细菌 on 2017/10/30.
//  Copyright © 2017年 reborn. All rights reserved.
//

#import "TestViewController.h"
#import <WebKit/WebKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

@interface TestViewController ()<WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate>

@property (strong , nonatomic) WKWebView* webView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.webView];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.bosinn.cn:8080/mpcctp/ios.html"]]];
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.bosinn.cn:8080/mpcctp/WKWeb.html"]]];
    
    //loadFileURL方法通常用于加载服务器的HTML页面或者JS，而loadHTMLString通常用于加载本地HTML或者JS
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WKWebViewMessageHandler" ofType:@"html"];
//    NSString *fileURL = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadHTMLString:fileURL baseURL:baseURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(WKWebView*)webView{
    if (!_webView) {
        //创建并配置WKWebView的相关参数
        //1.WKWebViewConfiguration:是WKWebView初始化时的配置类，里面存放着初始化WK的一系列属性；
        //2.WKUserContentController:为JS提供了一个发送消息的通道并且可以向页面注入JS的类，WKUserContentController对象可以添加多个scriptMessageHandler；
        //3.addScriptMessageHandler:name:有两个参数，第一个参数是userContentController的代理对象，第二个参数是JS里发送postMessage的对象。添加一个脚本消息的处理器,同时需要在JS中添加，window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        
        [userContentController addScriptMessageHandler:self name:@"Share"];
        [userContentController addScriptMessageHandler:self name:@"Camera"];
        
        configuration.userContentController = userContentController;
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //OC反馈给JS分享结果
//    NSString *JSResult = [NSString stringWithFormat:@"custId=%@",@"123"];
    NSString *JSResult = [NSString stringWithFormat:@"custID('%@')",@"12312312313"];
//    NSString* JSResult = @"123123123";
    
    //OC调用JS
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
     completionHandler();
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒222" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }]];
//
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- WKScriptMessageHandler
/**
 *  JS 调用 OC 时 webview 会调用此方法
 *
 *  @param userContentController  webview中配置的userContentController 信息
 *  @param message                JS执行传递的消息
 */

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //JS调用OC方法
    
    //message.boby就是JS里传过来的参数
    NSLog(@"body:%@",message.body);
    
    if ([message.name isEqualToString:@"Share"]) {
        [self ShareWithInformation:message.body];
        NSLog(@"share");
    } else if ([message.name isEqualToString:@"Camera"]) {
        NSLog(@"camera");
//        [self camera];
    }
    
}

#pragma mark - Method
- (void)ShareWithInformation:(NSDictionary *)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [dic objectForKey:@"title"];
    NSString *content = [dic objectForKey:@"content"];
    NSString *url = [dic objectForKey:@"url"];
    
    //在这里写分享操作的代码
    NSLog(@"要分享了哦😯");
    
    //OC反馈给JS分享结果
    NSString *JSResult = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
//    NSString *JSResult = @"123123123";
    //OC调用JS
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}
@end
