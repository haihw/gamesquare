//
//  ViewController.m
//  GameAboutSquares
//
//  Created by Hai Hw on 10/5/16.
//  Copyright © 2016 HW Inc. All rights reserved.
//
#define kGADBannerUnitID @"ca-app-pub-1931446035208028/5333497995"
#define kGADInterstitialUnitID @"ca-app-pub-1931446035208028/8147363599"
#import "ViewController.h"
#import "JTSReachabilityResponder.h"
@import GoogleMobileAds;
@interface ViewController () <UIWebViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate>
{
    NSURLRequest *myOnlyOneRequest;
    IBOutlet GADBannerView *gaBannerView;
    GADInterstitial *interstitial;
    BOOL networkWorking;
}
@property (strong, nonatomic) IBOutlet UIWebView *gameWebView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self reachabilitySetup];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _gameWebView.scrollView.scrollEnabled = NO;
    NSURL *gameURL = [NSURL URLWithString:@"http://www.gameaboutsquares.com"];
    myOnlyOneRequest = [NSURLRequest requestWithURL:gameURL];
    [_gameWebView loadRequest: myOnlyOneRequest];
    
    gaBannerView.adUnitID = kGADBannerUnitID;
    gaBannerView.rootViewController = self;
    [gaBannerView loadRequest:[GADRequest request]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reachabilitySetup {
    JTSReachabilityResponder *responder = [[JTSReachabilityResponder alloc] initWithOptionalHostname:nil];
    networkWorking = responder.isReachable;
    [responder addHandler:^(JTSNetworkStatus status) {
        // Respond to the value of "status"
        networkWorking = status != NotReachable;
    } forKey:@"MyReachabilityKey"];
}

- (IBAction)btnMenuTapped:(id)sender {
    NSLog(@"Show Menu");
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Delete Saved Game Data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *jsString = @"localStorage.clear();";
        [_gameWebView stringByEvaluatingJavaScriptFromString:jsString];
        if (networkWorking)
            [_gameWebView reload];
    }];
    
    UIAlertAction *unlockNextLevel = [UIAlertAction actionWithTitle:@"Unlock & Go To Next Level" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *jsString = @"localStorage.getItem('beavers');";
        NSString *currentUnlockedLevel = [_gameWebView stringByEvaluatingJavaScriptFromString:jsString];
        NSString *newLevel = [NSString stringWithFormat:@"%d", currentUnlockedLevel.intValue + 1];
        
        NSString *setValueJsString = [NSString stringWithFormat:@"localStorage.setItem('beavers', %@);", newLevel];

        [_gameWebView stringByEvaluatingJavaScriptFromString:setValueJsString];
        [self showAd];
        if (networkWorking)
            [_gameWebView reload];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:unlockNextLevel];
    [alertController addAction:resetAction];
    [alertController addAction:cancelAction];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = (UIButton*)sender;
    popPresenter.sourceRect = ((UIButton*)sender).bounds;
    [self presentViewController:alertController animated:YES completion:nil];
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
    [self createAndLoadInterstitial];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _gameWebView.hidden = YES;
}

#pragma Ad Handler
- (void)createAndLoadInterstitial {
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:kGADInterstitialUnitID];
    interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.
    [interstitial loadRequest:request];
}


- (void)showAd{
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:self];
    }
}

#pragma mark GADInterstitialDelegate implementation
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    NSLog(@"interstitialDidReceiveAd");
}
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    NSLog(@"interstitialWillPresentScreen");
}
- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
}

#pragma mark GADBannerViewDelegate implementation
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSLog(@"GAd banner did receive ad");
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"GAd failed: %@", error.localizedDescription);
}
@end
