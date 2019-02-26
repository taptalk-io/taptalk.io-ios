//
//  TAPImageDetailPreviewViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPImageDetailPreviewViewController.h"
#import "TAPImageDetailPreviewView.h"

#include <math.h>

@interface TAPImageDetailPreviewViewController () <TAPImageViewDelegate, UIScrollViewDelegate>

- (void)centerScrollViewContents;
- (void)refreshImageWithImage:(UIImage *)image;

@property (nonatomic) BOOL isLoading;

@end

@implementation TAPImageDetailPreviewViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    
    UIView *clippingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    clippingView.backgroundColor = [UIColor clearColor];
    clippingView.clipsToBounds = YES;
    [self.view addSubview:clippingView];
    
    _imageDetailPreviewView = [[TAPImageDetailPreviewView alloc] initWithFrame:self.view.bounds];
    [clippingView addSubview:self.imageDetailPreviewView];
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageDetailPreviewView.imageView.delegate = self;
    self.imageDetailPreviewView.zoomScrollView.delegate = self;
    
    if(self.thumbnailImage != nil && [self.thumbnailImage isKindOfClass:[UIImage class]]){
        self.imageDetailPreviewView.imageView.image = self.thumbnailImage;
    }
    [self refreshImageWithImage:self.imageDetailPreviewView.imageView.image];
    [self.imageDetailPreviewView addGestureRecognizer:self.tapGestureRecognizer];
    
    _isLoading = YES;
    [self.imageDetailPreviewView.activityIndicator startAnimating];
    [self.imageDetailPreviewView.zoomScrollView removeGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.imageDetailPreviewView setImage:self.image];
    [self.imageDetailPreviewView.zoomScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
//    [self.imageDetailPreviewView setImageURL:self.imageURL imageLocalName:self.imageLocalName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.imageDetailPreviewView.zoomScrollView.zoomScale = self.imageDetailPreviewView.zoomScrollView.minimumZoomScale;
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
    
    [self.imageDetailPreviewView.activityIndicator stopAnimating];
    [self.imageDetailPreviewView.zoomScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
}

#pragma mark - UIScrollView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageDetailPreviewView.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

#pragma mark - Custom Method
- (void)centerScrollViewContents {
    CGSize boundsSize = self.imageDetailPreviewView.zoomScrollView.bounds.size;
    CGRect contentsFrame = self.imageDetailPreviewView.imageView.frame;
    
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
    
    self.imageDetailPreviewView.imageView.frame = contentsFrame;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if([self.delegate respondsToSelector:@selector(imageDetailPreviewViewControllerDidHandleSingleTap)]) {
        [self.delegate imageDetailPreviewViewControllerDidHandleSingleTap];
    }
    
    if(self.imageDetailPreviewView.zoomScrollView.zoomScale > self.imageDetailPreviewView.zoomScrollView.minimumZoomScale) {
        return;
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    if([self.delegate respondsToSelector:@selector(imageDetailPreviewViewControllerDidHandleDoubleTap)]) {
        [self.delegate imageDetailPreviewViewControllerDidHandleDoubleTap];
    }
    
    if(self.imageDetailPreviewView.zoomScrollView.zoomScale >= self.imageDetailPreviewView.zoomScrollView.maximumZoomScale) {
        [self.imageDetailPreviewView.zoomScrollView setZoomScale:self.imageDetailPreviewView.zoomScrollView.minimumZoomScale animated:YES];
        
        return;
    }
    
    CGPoint pointInView = [gestureRecognizer locationInView:self.imageDetailPreviewView.imageView];
    
    CGFloat newZoomScale = self.imageDetailPreviewView.zoomScrollView.maximumZoomScale;
    
    CGSize scrollViewSize = self.imageDetailPreviewView.zoomScrollView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (width / 2.0f);
    CGFloat y = pointInView.y - (height / 2.0f);
    
    CGRect zoomRect = CGRectMake(x, y, width, height);
    
    [self.imageDetailPreviewView.zoomScrollView zoomToRect:zoomRect animated:YES];
}

- (UIImage *)currentImage {
    return self.imageDetailPreviewView.imageView.image;
}

- (void)refreshImageWithImage:(UIImage *)image {
    self.imageDetailPreviewView.imageView.frame = CGRectZero;
    self.imageDetailPreviewView.zoomScrollView.contentSize = self.imageDetailPreviewView.imageView.frame.size;
    self.imageDetailPreviewView.zoomScrollView.minimumZoomScale = 1.0f;
    self.imageDetailPreviewView.zoomScrollView.maximumZoomScale = 1.0f;
    self.imageDetailPreviewView.zoomScrollView.zoomScale = 1.0f;
    
    CGFloat photoZoomWidth = image.size.width;
    CGFloat photoZoomHeight = image.size.height;
    
    BOOL isPortrait = NO;
    
    if(photoZoomHeight > photoZoomWidth) {
        isPortrait = YES;
    }
    
    CGRect scrollViewFrame = self.imageDetailPreviewView.zoomScrollView.frame;
    
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
    
    self.imageDetailPreviewView.imageView.frame = CGRectMake(0.0f, 0.0f, photoZoomWidth, photoZoomHeight);
    self.imageDetailPreviewView.zoomScrollView.contentSize = self.imageDetailPreviewView.imageView.frame.size;
    
    CGFloat scaleWidth = CGRectGetWidth(scrollViewFrame) / self.imageDetailPreviewView.zoomScrollView.contentSize.width;
    CGFloat scaleHeight = CGRectGetHeight(scrollViewFrame) / self.imageDetailPreviewView.zoomScrollView.contentSize.height;
    
    CGFloat minimumZoomScale = scaleWidth;
    
    if((self.imageDetailPreviewView.zoomScrollView.contentSize.width * scaleHeight) < CGRectGetWidth([UIScreen mainScreen].bounds)) {
        minimumZoomScale = scaleHeight;
    }
    
    if(!self.isLoading) {
        self.imageDetailPreviewView.zoomScrollView.minimumZoomScale = minimumZoomScale;
        self.imageDetailPreviewView.zoomScrollView.maximumZoomScale = 1.0f;
        self.imageDetailPreviewView.zoomScrollView.zoomScale = minimumZoomScale;
    }
    
    [self centerScrollViewContents];
}

@end
