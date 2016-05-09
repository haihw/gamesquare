//
//  ViewController.m
//  GameAboutSquares
//
//  Created by Hai Hw on 10/5/16.
//  Copyright © 2016 HW Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>
{
    NSURLRequest *myOnlyOneRequest;
}
@property (strong, nonatomic) IBOutlet UIWebView *gameWebView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _gameWebView.scrollView.scrollEnabled = NO;
    _gameWebView.hidden = YES;
    NSURL *gameURL = [NSURL URLWithString:@"http://www.gameaboutsquares.com"];
    myOnlyOneRequest = [NSURLRequest requestWithURL:gameURL];
    [_gameWebView loadRequest: myOnlyOneRequest];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnMenuTapped:(id)sender {
    NSString *jsString = @"localStorage.clear();";
    [_gameWebView stringByEvaluatingJavaScriptFromString:jsString];
    NSLog(@"Clear and reload");
    [_gameWebView reload];
    
}

#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.host containsString:@"gameaboutsquares.com"])
        return YES;
    else
        return  NO;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _gameWebView.hidden = NO;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}
@end
