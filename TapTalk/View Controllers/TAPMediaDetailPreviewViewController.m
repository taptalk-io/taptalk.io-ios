//
//  TAPMediaDetailPreviewViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/1/19.
//

#import "TAPMediaDetailPreviewViewController.h"
#import "TAPMediaDetailPreviewView.h"

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

#include <math.h>

@interface TAPMediaDetailPreviewViewController () <TAPImageViewDelegate, UIScrollViewDelegate>

- (void)centerScrollViewContents;
- (void)refreshImageWithImage:(UIImage *)image;
- (void)playVideoButtonDidTapped;

@property (nonatomic) BOOL isLoading;

@end

@implementation TAPMediaDetailPreviewViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    
    UIView *clippingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    clippingView.backgroundColor = [UIColor clearColor];
    clippingView.clipsToBounds = YES;
    [self.view addSubview:clippingView];
    
    _mediaDetailPreviewView = [[TAPMediaDetailPreviewView alloc] initWithFrame:self.view.bounds];
    if (self.mediaDetailPreviewViewControllerType == TAPMediaDetailPreviewViewControllerTypeImage) {
        [self.mediaDetailPreviewView setMediaDetailPreviewViewType:TAPMediaDetailPreviewViewTypeImage];
    }
    else if (self.mediaDetailPreviewViewControllerType == TAPMediaDetailPreviewViewControllerTypeVideo) {
        [self.mediaDetailPreviewView setMediaDetailPreviewViewType:TAPMediaDetailPreviewViewTypeVideo];
    }
    [self.mediaDetailPreviewView.playVideoButton addTarget:self action:@selector(playVideoButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [clippingView addSubview:self.mediaDetailPreviewView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mediaDetailPreviewView.imageView.delegate = self;
    self.mediaDetailPreviewView.zoomScrollView.delegate = self;
    
    if(self.thumbnailImage != nil && [self.thumbnailImage isKindOfClass:[UIImage class]]){
        self.mediaDetailPreviewView.imageView.image = self.thumbnailImage;
    }
    [self refreshImageWithImage:self.mediaDetailPreviewView.imageView.image];
    [self.mediaDetailPreviewView addGestureRecognizer:self.tapGestureRecognizer];
    
    _isLoading = YES;
    [self.mediaDetailPreviewView.activityIndicator startAnimating];
    [self.mediaDetailPreviewView.zoomScrollView removeGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.mediaDetailPreviewView setImage:self.image];
    [self.mediaDetailPreviewView.zoomScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
//    [self.imageDetailPreviewView setImageURL:self.imageURL imageLocalName:self.imageLocalName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.mediaDetailPreviewView.zoomScrollView.zoomScale = self.mediaDetailPreviewView.zoomScrollView.minimumZoomScale;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Delegate
#pragma mark TAPImageView
- (void)imageViewDidFinishLoadImage:(TAPImageView *)imageView {
    _isLoading = NO;
    
    [self refreshImageWithImage:imageView.image];
    
    [self.mediaDetailPreviewView.activityIndicator stopAnimating];
    [self.mediaDetailPreviewView.zoomScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
}

#pragma mark - UIScrollView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mediaDetailPreviewView.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

#pragma mark - Custom Method
- (void)setMediaDetailPreviewViewControllerType:(TAPMediaDetailPreviewViewControllerType)mediaDetailPreviewViewControllerType {
    _mediaDetailPreviewViewControllerType = mediaDetailPreviewViewControllerType;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.mediaDetailPreviewView.zoomScrollView.bounds.size;
    CGRect contentsFrame = self.mediaDetailPreviewView.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mediaDetailPreviewView.imageView.frame = contentsFrame;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if([self.delegate respondsToSelector:@selector(mediaDetailPreviewViewControllerDidHandleSingleTap)]) {
        [self.delegate mediaDetailPreviewViewControllerDidHandleSingleTap];
    }
    
    if(self.mediaDetailPreviewView.zoomScrollView.zoomScale > self.mediaDetailPreviewView.zoomScrollView.minimumZoomScale) {
        return;
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    if (self.mediaDetailPreviewViewControllerType == TAPMediaDetailPreviewViewControllerTypeVideo) {
        //Only handle double tap when type is Image
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(mediaDetailPreviewViewControllerDidHandleDoubleTap)]) {
        [self.delegate mediaDetailPreviewViewControllerDidHandleDoubleTap];
    }
    
    if(self.mediaDetailPreviewView.zoomScrollView.zoomScale >= self.mediaDetailPreviewView.zoomScrollView.maximumZoomScale) {
        [self.mediaDetailPreviewView.zoomScrollView setZoomScale:self.mediaDetailPreviewView.zoomScrollView.minimumZoomScale animated:YES];
        
        return;
    }
    
    CGPoint pointInView = [gestureRecognizer locationInView:self.mediaDetailPreviewView.imageView];
    
    CGFloat newZoomScale = self.mediaDetailPreviewView.zoomScrollView.maximumZoomScale;
    
    CGSize scrollViewSize = self.mediaDetailPreviewView.zoomScrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    
    CGRect zoomRect = CGRectMake(x, y, width, height);
    
    [self.mediaDetailPreviewView.zoomScrollView zoomToRect:zoomRect animated:YES];
}

- (UIImage *)currentImage {
    return self.mediaDetailPreviewView.imageView.image;
}

- (void)refreshImageWithImage:(UIImage *)image {
    self.mediaDetailPreviewView.imageView.frame = CGRectZero;
    self.mediaDetailPreviewView.zoomScrollView.contentSize = self.mediaDetailPreviewView.imageView.frame.size;
    self.mediaDetailPreviewView.zoomScrollView.minimumZoomScale = 1.0f;
    self.mediaDetailPreviewView.zoomScrollView.maximumZoomScale = 1.0f;
    self.mediaDetailPreviewView.zoomScrollView.zoomScale = 1.0f;
    
    CGFloat photoZoomWidth = image.size.width;
    CGFloat photoZoomHeight = image.size.height;
    
    BOOL isPortrait = NO;
    
    if(photoZoomHeight > photoZoomWidth) {
        isPortrait = YES;
    }
    
    CGRect scrollViewFrame = self.mediaDetailPreviewView.zoomScrollView.frame;
    
    if(isPortrait) {
        if(photoZoomHeight < CGRectGetHeight(scrollViewFrame)) {
            photoZoomWidth = (CGRectGetHeight(scrollViewFrame)/photoZoomHeight) * photoZoomWidth;
            photoZoomHeight = CGRectGetHeight(scrollViewFrame);
        }
    }
    else {
        if(photoZoomWidth < CGRectGetWidth(scrollViewFrame)) {
            photoZoomHeight = (CGRectGetWidth(scrollViewFrame)/photoZoomWidth) * photoZoomHeight;
            photoZoomWidth = CGRectGetWidth(scrollViewFrame);
        }
    }
    
    self.mediaDetailPreviewView.imageView.frame = CGRectMake(0.0f, 0.0f, photoZoomWidth, photoZoomHeight);
    self.mediaDetailPreviewView.zoomScrollView.contentSize = self.mediaDetailPreviewView.imageView.frame.size;
    
    CGFloat scaleWidth = CGRectGetWidth(scrollViewFrame) / self.mediaDetailPreviewView.zoomScrollView.contentSize.width;
    CGFloat scaleHeight = CGRectGetHeight(scrollViewFrame) / self.mediaDetailPreviewView.zoomScrollView.contentSize.height;
    
    CGFloat minimumZoomScale = scaleWidth;
    
    if((self.mediaDetailPreviewView.zoomScrollView.contentSize.width * scaleHeight) < CGRectGetWidth([UIScreen mainScreen].bounds)) {
        minimumZoomScale = scaleHeight;
    }
    
    if(!self.isLoading) {
        self.mediaDetailPreviewView.zoomScrollView.minimumZoomScale = minimumZoomScale;
        self.mediaDetailPreviewView.zoomScrollView.maximumZoomScale = 1.0f;
        self.mediaDetailPreviewView.zoomScrollView.zoomScale = minimumZoomScale;
    }
    
    [self centerScrollViewContents];
}

- (void)playVideoButtonDidTapped {
//    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:resultVideoAsset];
//    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
//
//    if (self.showVideoPlayer) {
//        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
//        controller.delegate = self;
//        controller.showsPlaybackControls = YES;
//        [self presentViewController:controller animated:YES completion:nil];
//        controller.player = player;
//        [player play];
//    }
}

@end
