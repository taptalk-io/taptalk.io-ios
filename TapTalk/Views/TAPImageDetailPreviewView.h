//
//  TAPImageDetailPreviewView.h
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPImageDetailPreviewView : TAPBaseView

@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (strong, nonatomic) TAPImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

//- (void)setImageURL:(NSString *)imageURL imageLocalName:(NSString *)imageLocalName;
- (void)setImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
