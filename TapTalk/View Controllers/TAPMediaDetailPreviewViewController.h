//
//  TAPMediaDetailPreviewViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMediaDetailPreviewViewControllerType) {
    TAPMediaDetailPreviewViewControllerTypeImage = 0,
    TAPMediaDetailPreviewViewControllerTypeVideo = 1
};

@protocol TAPMediaDetailPreviewViewControllerDelegate <NSObject>

- (void)mediaDetailPreviewViewControllerDidHandleSingleTap;
- (void)mediaDetailPreviewViewControllerDidHandleDoubleTap;

@end

@class TAPMediaDetailPreviewView;

@interface TAPMediaDetailPreviewViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPMediaDetailPreviewViewControllerDelegate> delegate;
@property (strong, nonatomic) TAPMediaDetailPreviewView *mediaDetailPreviewView;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *imageLocalName;
@property (strong, nonatomic) UIImage *image;
//@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) TAPMediaDetailPreviewViewControllerType mediaDetailPreviewViewControllerType;

- (void)setMediaDetailPreviewViewControllerType:(TAPMediaDetailPreviewViewControllerType)mediaDetailPreviewViewControllerType;
- (UIImage *)currentImage;

@end

NS_ASSUME_NONNULL_END
