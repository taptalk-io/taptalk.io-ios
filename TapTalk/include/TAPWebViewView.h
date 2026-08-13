//
//  TAPWebViewView.h
//  TapTalk
//
//  Created by Cundy Sunardy on 28/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPWebViewView : TAPBaseView

@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *forwardButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *safariButton;
@property (strong, nonatomic) UIButton *refreshButton;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) WKWebView *webView;

- (void)setProgressViewWithProgress:(CGFloat)progress;
- (void)setBackButtonEnabled:(BOOL)enable;
- (void)setForwardButtonEnabled:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
