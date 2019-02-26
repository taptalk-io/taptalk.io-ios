//
//  TAPImageDetailPreviewViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPImageDetailPreviewViewControllerDelegate <NSObject>

- (void)imageDetailPreviewViewControllerDidHandleSingleTap;
- (void)imageDetailPreviewViewControllerDidHandleDoubleTap;

@end

@class TAPImageDetailPreviewView;

@interface TAPImageDetailPreviewViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPImageDetailPreviewViewControllerDelegate> delegate;
@property (strong, nonatomic) TAPImageDetailPreviewView *imageDetailPreviewView;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *imageLocalName;
@property (strong, nonatomic) UIImage *image;
//@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

- (UIImage *)currentImage;

@end

NS_ASSUME_NONNULL_END
