//
//  TAPMediaDetailPreviewView.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMediaDetailPreviewViewType) {
    TAPMediaDetailPreviewViewTypeImage = 0,
    TAPMediaDetailPreviewViewTypeVideo = 1
};

@interface TAPMediaDetailPreviewView : TAPBaseView

@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (strong, nonatomic) TAPImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *playVideoButton;
@property (nonatomic) TAPMediaDetailPreviewViewType mediaDetailPreviewViewType;

//- (void)setImageURL:(NSString *)imageURL imageLocalName:(NSString *)imageLocalName;
- (void)setImage:(UIImage *)image;
- (void)setMediaDetailPreviewViewType:(TAPMediaDetailPreviewViewType)mediaDetailPreviewViewType;

@end

NS_ASSUME_NONNULL_END
