//
//  TAPWebViewViewController.m
//  TapTalk
//
//  Created by Cundy Sunardy on 28/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPWebViewViewController.h"
#import "TAPWebViewView.h"

@interface TAPWebViewViewController () <WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) TAPWebViewView *tapWebViewView;
@property (nonatomic) CGFloat minimumProgress;

- (void)doneButtonDidTapped;
- (void)refreshButtonDidTapped;
- (void)backButtonDidTapped;
- (void)forwardButtonDidTapped;
- (void)shareButtonDidTapped;
- (void)safariButtonDidTapped;

@end

@implementation TAPWebViewViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _tapWebViewView = [[TAPWebViewView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.tapWebViewView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tapWebViewView.doneButton addTarget:self action:@selector(doneButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tapWebViewView.shareButton addTarget:self action:@selector(shareButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tapWebViewView.refreshButton addTarget:self action:@selector(refreshButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tapWebViewView.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tapWebViewView.forwardButton addTarget:self action:@selector(forwardButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tapWebViewView.safariButton addTarget:self action:@selector(safariButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.tapWebViewView.webView.navigationDelegate = self;
    self.tapWebViewView.webView.UIDelegate = self;
    self.tapWebViewView.webView.scrollView.delegate = self;
    _minimumProgress = 0.3f;
    
    [self loadWebView];
    [self updateBackForwardState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tapWebViewView.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tapWebViewView.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)dealloc {
    //need to set all webview delegate to nil to prevent crash on webview finish loading after view deallocated
    self.tapWebViewView.webView.navigationDelegate = nil;
    self.tapWebViewView.webView.UIDelegate = nil;
    self.tapWebViewView.webView.scrollView.delegate = nil;
    [self.tapWebViewView.webView stopLoading];
}

#pragma mark - Delegate
#pragma mark WKWebView
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateBackForwardState];
    
    NSString *titleString = self.tapWebViewView.webView.URL.absoluteString;
    
    if ([titleString hasPrefix:@"http://"]) {
        titleString = [titleString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    else if ([titleString hasPrefix:@"https://"]) {
        titleString = [titleString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    
    if ([titleString hasSuffix:@"/"]) {
        titleString = [titleString stringByReplacingCharactersInRange:NSMakeRange([titleString length] - 1, 1) withString:@""];
    }
    
    self.tapWebViewView.titleLabel.text = titleString;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
//    //DV Note - Script to remove highlight color of webview when tapped / selected
    NSString *script = @"function addStyleString(str) {var node = document.createElement('style'); node.innerHTML = str; document.body.appendChild(node); } addStyleString('* {-webkit-tap-highlight-color: rgba(0,0,0,0);}');";
    [webView evaluateJavaScript:script completionHandler:nil];

    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.scrollView.backgroundColor = [UIColor clearColor];
    
    [self updateBackForwardState];
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat startYOffset = 20.0f;
    if(IS_IPHONE_X_FAMILY) {
        startYOffset = 44.0f;
    }
    
    CGFloat scrollviewYOffset = scrollView.contentOffset.y;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
    
}

#pragma mark - Custom Method
- (void)doneButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshButtonDidTapped {
    [self.tapWebViewView.webView reload];
}

- (void)backButtonDidTapped {
    [self.tapWebViewView.webView goBack];
    [self updateBackForwardState];
}

- (void)forwardButtonDidTapped {
    [self.tapWebViewView.webView goForward];
    [self updateBackForwardState];
}

- (void)shareButtonDidTapped {
    NSString *shareTextWithURL = self.tapWebViewView.webView.URL.absoluteString;
    
    NSArray *activityItems = @[shareTextWithURL];
    NSArray *applicationActivities = nil;
    UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)safariButtonDidTapped {
    if(IS_IOS_11_OR_ABOVE) {
        [[UIApplication sharedApplication] openURL:self.tapWebViewView.webView.URL options:[NSDictionary dictionary] completionHandler:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:self.tapWebViewView.webView.URL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.tapWebViewView.webView) {
        if (self.tapWebViewView.webView.estimatedProgress < self.minimumProgress) {
            //BELOW minimumProgress will be forced to minimumProgress
            [self.tapWebViewView setProgressViewWithProgress:self.minimumProgress];
        }
        else {
            [self.tapWebViewView setProgressViewWithProgress:self.tapWebViewView.webView.estimatedProgress];
        }
    }
}

- (void)loadWebView {
    if (self.urlString != nil && ![self.urlString isEqualToString:@""]) {
        self.tapWebViewView.webView.allowsBackForwardNavigationGestures = YES;
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
        [self.tapWebViewView.webView loadRequest:urlReq];
    }
}

- (void)updateBackForwardState {
    if ([self.tapWebViewView.webView canGoBack]) {
        [self.tapWebViewView setBackButtonEnabled:YES];
    }
    else {
        [self.tapWebViewView setBackButtonEnabled:NO];
    }
    
    if ([self.tapWebViewView.webView canGoForward]) {
        [self.tapWebViewView setForwardButtonEnabled:YES];
    }
    else {
        [self.tapWebViewView setForwardButtonEnabled:NO];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
