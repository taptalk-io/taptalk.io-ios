//
//  TAPMediaDetailViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPMediaDetailViewController.h"
#import "TAPMediaDetailPreviewViewController.h"
#import "TAPMediaDetailView.h"
#import "TAPMediaDetailPreviewView.h"
//#import "AppDelegate.h"

@interface TAPMediaDetailViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, TAPMediaDetailViewDelegate, TAPMediaDetailPreviewViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *thumbnailImage;
@property (nonatomic) CGRect thumbnailFrame;

@property (nonatomic) CGPoint startPanPoint;
@property (nonatomic) CGPoint lastPanPoint;
@property (nonatomic) CGFloat lastXGap;
@property (nonatomic) CGFloat lastYGap;

@property (nonatomic) BOOL isHeaderFooterViewShown;
@property (nonatomic) BOOL isActiveIndexSet;
@property (nonatomic) BOOL isWillTransitionCalled;
@property (nonatomic) NSInteger currentActiveIndex;

@property (strong, nonatomic) NSMutableDictionary *viewControllerDictionary;

@property (weak, nonatomic) TAPMediaDetailPreviewViewController *currentViewController;

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)dismissSelf;
- (void)showFinishSavingImageState;
- (void)removeSaveImageLoadingView;

@end

@implementation TAPMediaDetailViewController

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    
    if(self) {
        _contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    _viewControllerDictionary = [[NSMutableDictionary alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _mediaDetailView = [[TAPMediaDetailView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    self.mediaDetailView.contentMode = self.contentMode;
    self.mediaDetailView.delegate = self;
    
    if (self.mediaDetailViewControllerType == TAPMediaDetailViewControllerTypeImage) {
        [self.mediaDetailView setMediaDetailViewType:TAPMediaDetailViewTypeImage];
    }
    else if (self.mediaDetailViewControllerType == TAPMediaDetailViewControllerTypeVideo) {
        [self.mediaDetailView setMediaDetailViewType:TAPMediaDetailViewTypeVideo];
    }

    [self.view addSubview:self.mediaDetailView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mediaDetailView.pageViewController.delegate = self;
    self.mediaDetailView.pageViewController.dataSource = self;
    [self addChildViewController:self.mediaDetailView.pageViewController];
    [self.mediaDetailView.pageViewController didMoveToParentViewController:self];
    [self.mediaDetailView.pageViewController.view addGestureRecognizer:self.panGestureRecognizer];
    
    for (UIView *view in self.mediaDetailView.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setDelegate:self];
        }
    }
    
    _isActiveIndexSet = NO;
    if(self.isActiveIndexSet) {
        [self setActiveIndex:self.currentActiveIndex];
        
        _isActiveIndexSet = NO;
    }
    else {
        TAPMediaDetailPreviewViewController *initialViewController = [self viewControllerAtIndex:0];
        _currentViewController = initialViewController;
        initialViewController.view.backgroundColor = [UIColor clearColor];
        
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [self.mediaDetailView.pageViewController setViewControllers:viewControllers
                                                        direction:UIPageViewControllerNavigationDirectionForward
                                                         animated:NO
                                                       completion:nil];
    }
    
    //Remove swipe to back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //Show header footer info view
    _isHeaderFooterViewShown = YES;
    [self.mediaDetailView showHeaderAndCaptionView:self.isHeaderFooterViewShown animated:NO];
    [self.mediaDetailView setMediaDetailInfoWithMessage:self.message];
    
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

#pragma mark - UIPageViewController
#pragma mark Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController  *)viewController {
    NSInteger index = [(TAPMediaDetailPreviewViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [(TAPMediaDetailPreviewViewController *)viewController index];
    
    index++;
    
    if (index == [self.imageArray count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

#pragma mark Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _isWillTransitionCalled = YES;
    TAPMediaDetailPreviewViewController *pendingViewController = (TAPMediaDetailPreviewViewController *)[pendingViewControllers objectAtIndex:0];
    NSInteger index = pendingViewController.index;
    _currentActiveIndex = index;
    _currentViewController = pendingViewController;
    
    if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerWillChangeToPage:)]) {
        [self.delegate mediaDetailViewControllerWillChangeToPage:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(!completed) {
        TAPMediaDetailPreviewViewController *previousViewController = (TAPMediaDetailPreviewViewController *)[previousViewControllers objectAtIndex:0];
        NSInteger index = previousViewController.index;
        _currentActiveIndex = index;
        _currentViewController = previousViewController;
        
        if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerWillChangeToPage:)]) {
            [self.delegate mediaDetailViewControllerWillChangeToPage:index];
        }
    }
    
    _isWillTransitionCalled = NO;
}

#pragma mark - Delegate
#pragma mark MediaDetailView
- (void)mediaDetailViewDidFinishOpeningAnimation {
    if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerDidFinishOpeningAnimation)]) {
        [self.delegate mediaDetailViewControllerDidFinishOpeningAnimation];
    }
}

- (void)mediaDetailViewDidFinishClosingAnimation {
    if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerDidFinishClosingAnimation)]) {
        [self.delegate mediaDetailViewControllerDidFinishClosingAnimation];
    }
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)mediaDetailViewWillStartOpeningAnimation {
    if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerWillStartOpeningAnimation)]) {
        [self.delegate mediaDetailViewControllerWillStartOpeningAnimation];
    }
}

- (void)mediaDetailViewWillStartClosingAnimation {
    if([self.delegate respondsToSelector:@selector(mediaDetailViewControllerWillStartClosingAnimation)]) {
        [self.delegate mediaDetailViewControllerWillStartClosingAnimation];
    }
}

- (void)mediaDetailViewDidTappedSaveImageButton {
    [self.mediaDetailView setSaveLoadingAsFinishedState:NO];
    [self.mediaDetailView showSaveLoadingView:YES];
    UIImage *currentImage = [self.imageArray firstObject];
    UIImageWriteToSavedPhotosAlbum(currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)mediaDetailViewDidTappedSaveVideoButton {

}

- (void)mediaDetailViewDidTappedBackButton {
    [self.mediaDetailView showHeaderAndCaptionView:NO animated:YES];
    [self dismissSelf];
}

#pragma mark MediaDetailPreviewViewController
- (void)mediaDetailPreviewViewControllerDidHandleSingleTap {
    _isHeaderFooterViewShown = !self.isHeaderFooterViewShown;
    [self.mediaDetailView showHeaderAndCaptionView:self.isHeaderFooterViewShown animated:YES];
}

- (void)mediaDetailPreviewViewControllerDidHandleDoubleTap {
    
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isWillTransitionCalled) {
        return;
    }
    
    CGFloat movementPercentage = (scrollView.contentOffset.x - CGRectGetWidth(self.mediaDetailView.pageViewController.view.frame))/CGRectGetWidth(self.mediaDetailView.pageViewController.view.frame);
    
    if(movementPercentage > 0.0f) {
        //Move to the left
        TAPMediaDetailPreviewViewController *currentViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex - 1]];
        
        CGFloat maxGap = (CGRectGetWidth(self.mediaDetailView.pageViewController.view.frame) - CGRectGetWidth(currentViewController.mediaDetailPreviewView.frame)) * 4.0f;
        
        CGFloat currentViewControllerX = fabs(movementPercentage) * maxGap;
        
        TAPMediaDetailPreviewViewController *nextViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex]];
        
        CGFloat nextViewControllerX = -(maxGap - currentViewControllerX);
        
        nextViewController.mediaDetailPreviewView.frame = CGRectMake(nextViewControllerX, CGRectGetMinY(nextViewController.mediaDetailPreviewView.frame), CGRectGetWidth(nextViewController.mediaDetailPreviewView.frame), CGRectGetHeight(nextViewController.mediaDetailPreviewView.frame));
        
        currentViewController.mediaDetailPreviewView.frame = CGRectMake(currentViewControllerX, CGRectGetMinY(currentViewController.mediaDetailPreviewView.frame), CGRectGetWidth(currentViewController.mediaDetailPreviewView.frame), CGRectGetHeight(currentViewController.mediaDetailPreviewView.frame));
    }
    else if(movementPercentage < 0.0f) {
        //Move to the right
        TAPMediaDetailPreviewViewController *currentViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex + 1]];
        
        CGFloat maxGap = (CGRectGetWidth(self.mediaDetailView.pageViewController.view.frame) - CGRectGetWidth(currentViewController.mediaDetailPreviewView.frame)) * 2.0f;
        
        CGFloat currentViewControllerX = -(fabs(movementPercentage) * maxGap);
        
        TAPMediaDetailPreviewViewController *nextViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex]];
        
        CGFloat nextViewControllerX = maxGap + currentViewControllerX;
        
        nextViewController.mediaDetailPreviewView.frame = CGRectMake(nextViewControllerX, CGRectGetMinY(nextViewController.mediaDetailPreviewView.frame), CGRectGetWidth(nextViewController.mediaDetailPreviewView.frame), CGRectGetHeight(nextViewController.mediaDetailPreviewView.frame));
        
        currentViewController.mediaDetailPreviewView.frame = CGRectMake(currentViewControllerX, CGRectGetMinY(currentViewController.mediaDetailPreviewView.frame), CGRectGetWidth(currentViewController.mediaDetailPreviewView.frame), CGRectGetHeight(currentViewController.mediaDetailPreviewView.frame));
    }
}

#pragma mark - Custom Method
- (void)setMediaDetailViewControllerType:(TAPMediaDetailViewControllerType)mediaDetailViewControllerType {
    _mediaDetailViewControllerType = mediaDetailViewControllerType;
}

- (TAPMediaDetailPreviewViewController *)viewControllerAtIndex:(NSUInteger)index {
    TAPMediaDetailPreviewViewController *mediaDetailPreviewViewController = [[TAPMediaDetailPreviewViewController alloc] init];

    if (self.mediaDetailViewControllerType == TAPMediaDetailViewControllerTypeImage) {
        [mediaDetailPreviewViewController setMediaDetailPreviewViewControllerType:TAPMediaDetailPreviewViewControllerTypeImage];
    }
    else if (self.mediaDetailViewControllerType == TAPMediaDetailViewControllerTypeVideo) {
        [mediaDetailPreviewViewController setMediaDetailPreviewViewControllerType:TAPMediaDetailPreviewViewControllerTypeVideo];
    }

    mediaDetailPreviewViewController.index = index;
    if(self.thumbnailImageArray != nil && [self.thumbnailImageArray count] > 0 && index < [self.thumbnailImageArray count]) {
        mediaDetailPreviewViewController.thumbnailImage = [self.thumbnailImageArray objectAtIndex:index];
    }
    
    if(self.imageLocalNameArray != nil && [self.imageLocalNameArray count] > 0 && index < [self.imageLocalNameArray count]) {
        mediaDetailPreviewViewController.imageLocalName = [self.imageLocalNameArray objectAtIndex:index];
    }
    
    if(self.imageArray != nil && [self.imageArray count] > 0 && index < [self.imageArray count]) {
        mediaDetailPreviewViewController.image = [self.imageArray objectAtIndex:index];
    }
    
    mediaDetailPreviewViewController.delegate = self;
    
    [self.viewControllerDictionary setObject:mediaDetailPreviewViewController forKey:[NSNumber numberWithInteger:index]];
    
    return mediaDetailPreviewViewController;
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    
    CGFloat minimumGapToAction = 50.0f;
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //Hide header and footer view
        [self.mediaDetailView showHeaderAndCaptionView:NO animated:NO];
        
        _startPanPoint = location;
        _lastPanPoint = location;
    }
    else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat lastX = self.lastPanPoint.x;
        CGFloat currentX = location.x;
        CGFloat currentXGap = currentX - lastX;
        
        CGFloat lastY = self.lastPanPoint.y;
        CGFloat currentY = location.y;
        CGFloat currentYGap = currentY - lastY;
        
        CGFloat newX = CGRectGetMinX(self.mediaDetailView.movementView.frame) + currentXGap;
        CGFloat newY = CGRectGetMinY(self.mediaDetailView.movementView.frame) + currentYGap;
        
        CGRect pageViewControllerView = self.mediaDetailView.movementView.frame;
        
        self.mediaDetailView.movementView.frame = CGRectMake(newX, newY, CGRectGetWidth(pageViewControllerView), CGRectGetHeight(pageViewControllerView));
        
        _lastPanPoint = location;
        _lastXGap = currentXGap;
        _lastYGap = currentYGap;
        
        CGFloat firstY = self.startPanPoint.y;
        CGFloat endY = location.y;
        CGFloat endYGap = endY - firstY;
        
        if(endYGap < 0.0f) {
            endYGap *= -1;
        }
        
        CGFloat alphaAdjuster = 0.2f; //Add more alpha from gap counter
        CGFloat alphaDecreaserDivider = 2.0f; //How many times from gap to 0.0f alpha
        
        CGFloat backgroundAlpha = (1.0f - (endYGap/(minimumGapToAction * alphaDecreaserDivider))) + alphaAdjuster;
        self.mediaDetailView.backgroundView.alpha = backgroundAlpha;
    }
    else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat firstY = self.startPanPoint.y;
        CGFloat endY = location.y;
        CGFloat endYGap = endY - firstY;
        
        if(endYGap < 0.0f) {
            if(endYGap > -minimumGapToAction) {
                //Cancel
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                     usingSpringWithDamping:0.8f
                      initialSpringVelocity:0.8f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.mediaDetailView.movementView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.mediaDetailView.movementView.frame), CGRectGetHeight(self.mediaDetailView.movementView.frame));
                                     self.mediaDetailView.backgroundView.alpha = 1.0f;
                                 } completion:nil];
             
                //Show header and footer view
                if (self.isHeaderFooterViewShown) {
                    [self.mediaDetailView showHeaderAndCaptionView:YES animated:YES];
                }
                
                return;
            }
            
            //Dismiss Action
            [self dismissSelf];
        }
        else {
            if(endYGap < minimumGapToAction) {
                //Cancel
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                     usingSpringWithDamping:0.8f
                      initialSpringVelocity:0.8f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.mediaDetailView.movementView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.mediaDetailView.movementView.frame), CGRectGetHeight(self.mediaDetailView.movementView.frame));
                                     self.mediaDetailView.backgroundView.alpha = 1.0f;
                                 } completion:nil];
                
                //Show header and footer view
                if (self.isHeaderFooterViewShown) {
                    [self.mediaDetailView showHeaderAndCaptionView:YES animated:YES];
                }
                
                return;
            }
            
            //Dismiss Action
            [self dismissSelf];
        }
    }
}

- (void)showToViewController:(UIViewController *)viewController
              thumbnailImage:(UIImage *)thumbnailImage
              thumbnailFrame:(CGRect)thumbnailFrame {
    [viewController addChildViewController:self];
    [self didMoveToParentViewController:viewController];
    self.view.backgroundColor = [UIColor clearColor];
    [viewController.view addSubview:self.view];
    _thumbnailFrame = thumbnailFrame;
    _thumbnailImage = thumbnailImage;
    
    [self.mediaDetailView animateOpeningWithThumbnailFrame:thumbnailFrame thumbnailImage:thumbnailImage];
}

- (void)dismissSelf {
    UIImage *thumbnailImage = [UIImage imageNamed:@"blank-image"];
    
    if(self.currentViewController != nil) {
        thumbnailImage = [self.currentViewController currentImage];
    }
    
    [self.mediaDetailView animateClosingWithThumbnailFrame:self.thumbnailFrame thumbnailImage:thumbnailImage];
}

- (void)setActiveIndex:(NSInteger)activeIndex {
    if(![self isViewLoaded]) {
        _isActiveIndexSet = YES;
        _currentActiveIndex = activeIndex;
        
        return;
    }
    
    TAPMediaDetailPreviewViewController *nextController = [self viewControllerAtIndex:activeIndex];
    _currentViewController = nextController;
    
    if (nextController) {
        NSArray *viewControllers = @[nextController];
        // This changes the View Controller and calls the presentationIndexForPageViewController datasource method
        [self.mediaDetailView.pageViewController setViewControllers:viewControllers
                                                        direction:UIPageViewControllerNavigationDirectionForward
                                                         animated:YES
                                                       completion:nil];
    }
}

//Override completionSelector method of save image to gallery
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self showFinishSavingImageState];
}

- (void)showFinishSavingImageState {
    [self.mediaDetailView setSaveLoadingAsFinishedState:YES];
    [self performSelector:@selector(removeSaveImageLoadingView) withObject:nil afterDelay:1.0f];
}

- (void)removeSaveImageLoadingView {
    [self.mediaDetailView showSaveLoadingView:NO];
}

@end
