//
//  TAPImageDetailViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPImageDetailViewController.h"
#import "TAPImageDetailPreviewViewController.h"
#import "TAPImageDetailView.h"
#import "TAPImageDetailPreviewView.h"
//#import "AppDelegate.h"

@interface TAPImageDetailViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, TAPImageDetailViewDelegate, TAPImageDetailPreviewViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *thumbnailImage;
@property (nonatomic) CGRect thumbnailFrame;

@property (nonatomic) CGPoint startPanPoint;
@property (nonatomic) CGPoint lastPanPoint;
@property (nonatomic) CGFloat lastXGap;
@property (nonatomic) CGFloat lastYGap;

@property (nonatomic) BOOL isBottomBarInitallyHidden;
@property (nonatomic) BOOL isActiveIndexSet;
@property (nonatomic) BOOL isWillTransitionCalled;
@property (nonatomic) NSInteger currentActiveIndex;

@property (strong, nonatomic) NSMutableDictionary *viewControllerDictionary;

@property (weak, nonatomic) TAPImageDetailPreviewViewController *currentViewController;

- (void)dismissSelf;

@end

@implementation TAPImageDetailViewController

#pragma mark - Lifecycle
- (id)init {
    self = [super init];
    
    if(self) {
        _contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    _viewControllerDictionary = [[NSMutableDictionary alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _imageDetailView = [[TAPImageDetailView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    self.imageDetailView.contentMode = self.contentMode;
    self.imageDetailView.delegate = self;
    [self.view addSubview:self.imageDetailView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageDetailView.pageViewController.delegate = self;
    self.imageDetailView.pageViewController.dataSource = self;
    [self addChildViewController:self.imageDetailView.pageViewController];
    [self.imageDetailView.pageViewController didMoveToParentViewController:self];
    [self.imageDetailView.pageViewController.view addGestureRecognizer:self.panGestureRecognizer];
    
    for (UIView *view in self.imageDetailView.pageViewController.view.subviews) {
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
        TAPImageDetailPreviewViewController *initialViewController = [self viewControllerAtIndex:0];
        _currentViewController = initialViewController;
        initialViewController.view.backgroundColor = [UIColor clearColor];
        
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [self.imageDetailView.pageViewController setViewControllers:viewControllers
                                                        direction:UIPageViewControllerNavigationDirectionForward
                                                         animated:NO
                                                       completion:nil];
    }
    
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
    NSInteger index = [(TAPImageDetailPreviewViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [(TAPImageDetailPreviewViewController *)viewController index];
    
    index++;
    
    if (index == [self.imageArray count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

#pragma mark Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    _isWillTransitionCalled = YES;
    TAPImageDetailPreviewViewController *pendingViewController = (TAPImageDetailPreviewViewController *)[pendingViewControllers objectAtIndex:0];
    NSInteger index = pendingViewController.index;
    _currentActiveIndex = index;
    _currentViewController = pendingViewController;
    
    if([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillChangeToPage:)]) {
        [self.delegate imageDetailViewControllerWillChangeToPage:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(!completed) {
        TAPImageDetailPreviewViewController *previousViewController = (TAPImageDetailPreviewViewController *)[previousViewControllers objectAtIndex:0];
        NSInteger index = previousViewController.index;
        _currentActiveIndex = index;
        _currentViewController = previousViewController;
        
        if([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillChangeToPage:)]) {
            [self.delegate imageDetailViewControllerWillChangeToPage:index];
        }
    }
    
    _isWillTransitionCalled = NO;
}

#pragma mark - Delegate
#pragma mark imageDetailView
- (void)imageDetailViewDidFinishOpeningAnimation {
    if([self.delegate respondsToSelector:@selector(imageDetailViewControllerDidFinishOpeningAnimation)]) {
        [self.delegate imageDetailViewControllerDidFinishOpeningAnimation];
    }
}

- (void)imageDetailViewDidFinishClosingAnimation {
    if([self.delegate respondsToSelector:@selector(imageDetailViewControllerDidFinishClosingAnimation)]) {
        [self.delegate imageDetailViewControllerDidFinishClosingAnimation];
    }
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)imageDetailViewWillStartOpeningAnimation {
    if([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillStartOpeningAnimation)]) {
        [self.delegate imageDetailViewControllerWillStartOpeningAnimation];
    }
}

- (void)imageDetailViewWillStartClosingAnimation {
    if([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillStartClosingAnimation)]) {
        [self.delegate imageDetailViewControllerWillStartClosingAnimation];
    }
}

#pragma mark ImageDetailPreviewViewController
- (void)imageDetailPreviewViewControllerDidTapped {
    [self dismissSelf];
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isWillTransitionCalled) {
        return;
    }
    
    CGFloat movementPercentage = (scrollView.contentOffset.x - CGRectGetWidth(self.imageDetailView.pageViewController.view.frame))/CGRectGetWidth(self.imageDetailView.pageViewController.view.frame);
    
    if(movementPercentage > 0.0f) {
        //Move to the left
        TAPImageDetailPreviewViewController *currentViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex - 1]];
        
        CGFloat maxGap = (CGRectGetWidth(self.imageDetailView.pageViewController.view.frame) - CGRectGetWidth(currentViewController.imageDetailPreviewView.frame)) * 4.0f;
        
        CGFloat currentViewControllerX = fabs(movementPercentage) * maxGap;
        
        TAPImageDetailPreviewViewController *nextViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex]];
        
        CGFloat nextViewControllerX = -(maxGap - currentViewControllerX);
        
        nextViewController.imageDetailPreviewView.frame = CGRectMake(nextViewControllerX, CGRectGetMinY(nextViewController.imageDetailPreviewView.frame), CGRectGetWidth(nextViewController.imageDetailPreviewView.frame), CGRectGetHeight(nextViewController.imageDetailPreviewView.frame));
        
        currentViewController.imageDetailPreviewView.frame = CGRectMake(currentViewControllerX, CGRectGetMinY(currentViewController.imageDetailPreviewView.frame), CGRectGetWidth(currentViewController.imageDetailPreviewView.frame), CGRectGetHeight(currentViewController.imageDetailPreviewView.frame));
    }
    else if(movementPercentage < 0.0f) {
        //Move to the right
        TAPImageDetailPreviewViewController *currentViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex + 1]];
        
        CGFloat maxGap = (CGRectGetWidth(self.imageDetailView.pageViewController.view.frame) - CGRectGetWidth(currentViewController.imageDetailPreviewView.frame)) * 2.0f;
        
        CGFloat currentViewControllerX = -(fabs(movementPercentage) * maxGap);
        
        TAPImageDetailPreviewViewController *nextViewController = [self.viewControllerDictionary objectForKey:[NSNumber numberWithInteger:self.currentActiveIndex]];
        
        CGFloat nextViewControllerX = maxGap + currentViewControllerX;
        
        nextViewController.imageDetailPreviewView.frame = CGRectMake(nextViewControllerX, CGRectGetMinY(nextViewController.imageDetailPreviewView.frame), CGRectGetWidth(nextViewController.imageDetailPreviewView.frame), CGRectGetHeight(nextViewController.imageDetailPreviewView.frame));
        
        currentViewController.imageDetailPreviewView.frame = CGRectMake(currentViewControllerX, CGRectGetMinY(currentViewController.imageDetailPreviewView.frame), CGRectGetWidth(currentViewController.imageDetailPreviewView.frame), CGRectGetHeight(currentViewController.imageDetailPreviewView.frame));
    }
}

#pragma mark - Custom Method
- (TAPImageDetailPreviewViewController *)viewControllerAtIndex:(NSUInteger)index {
    TAPImageDetailPreviewViewController *imageDetailPreviewViewController = [[TAPImageDetailPreviewViewController alloc] init];
    imageDetailPreviewViewController.index = index;
    if(self.thumbnailImageArray != nil && [self.thumbnailImageArray count] > 0 && index < [self.thumbnailImageArray count]) {
        imageDetailPreviewViewController.thumbnailImage = [self.thumbnailImageArray objectAtIndex:index];
    }
    
    if(self.imageLocalNameArray != nil && [self.imageLocalNameArray count] > 0 && index < [self.imageLocalNameArray count]) {
        imageDetailPreviewViewController.imageLocalName = [self.imageLocalNameArray objectAtIndex:index];
    }
    
    if(self.imageArray != nil && [self.imageArray count] > 0 && index < [self.imageArray count]) {
        imageDetailPreviewViewController.image = [self.imageArray objectAtIndex:index];
    }
    
    imageDetailPreviewViewController.delegate = self;
    
    [self.viewControllerDictionary setObject:imageDetailPreviewViewController forKey:[NSNumber numberWithInteger:index]];
    
    return imageDetailPreviewViewController;
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    
    CGFloat minimumGapToAction = 50.0f;
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
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
        
        CGFloat newX = CGRectGetMinX(self.imageDetailView.movementView.frame) + currentXGap;
        CGFloat newY = CGRectGetMinY(self.imageDetailView.movementView.frame) + currentYGap;
        
        CGRect pageViewControllerView = self.imageDetailView.movementView.frame;
        
        self.imageDetailView.movementView.frame = CGRectMake(newX, newY, CGRectGetWidth(pageViewControllerView), CGRectGetHeight(pageViewControllerView));
        
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
        self.imageDetailView.backgroundView.alpha = backgroundAlpha;
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
                                     self.imageDetailView.movementView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.imageDetailView.movementView.frame), CGRectGetHeight(self.imageDetailView.movementView.frame));
                                     self.imageDetailView.backgroundView.alpha = 1.0f;
                                 } completion:nil];
                
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
                                     self.imageDetailView.movementView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.imageDetailView.movementView.frame), CGRectGetHeight(self.imageDetailView.movementView.frame));
                                     self.imageDetailView.backgroundView.alpha = 1.0f;
                                 } completion:nil];
                
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
    
    [self.imageDetailView animateOpeningWithThumbnailFrame:thumbnailFrame thumbnailImage:thumbnailImage];
}

- (void)dismissSelf {
    UIImage *thumbnailImage = [UIImage imageNamed:@"blank-image"];
    
    if(self.currentViewController != nil) {
        thumbnailImage = [self.currentViewController currentImage];
    }
    
    [self.imageDetailView animateClosingWithThumbnailFrame:self.thumbnailFrame thumbnailImage:thumbnailImage];
}

- (void)setActiveIndex:(NSInteger)activeIndex {
    if(![self isViewLoaded]) {
        _isActiveIndexSet = YES;
        _currentActiveIndex = activeIndex;
        
        return;
    }
    
    TAPImageDetailPreviewViewController *nextController = [self viewControllerAtIndex:activeIndex];
    _currentViewController = nextController;
    
    if (nextController) {
        NSArray *viewControllers = @[nextController];
        // This changes the View Controller and calls the presentationIndexForPageViewController datasource method
        [self.imageDetailView.pageViewController setViewControllers:viewControllers
                                                        direction:UIPageViewControllerNavigationDirectionForward
                                                         animated:YES
                                                       completion:nil];
    }
}

@end
