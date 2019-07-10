//
//  TAPMediaDetailPreviewView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 29/1/19.
//

#import "TAPMediaDetailPreviewView.h"

@interface TAPMediaDetailPreviewView ()

@property (strong, nonatomic) UIImageView *playVideoButtonImageView;

- (void)setViewStateWithType:(TAPMediaDetailPreviewViewType)type;

@end

@implementation TAPMediaDetailPreviewView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.activityIndicator.frame = CGRectMake((CGRectGetWidth(self.frame) - CGRectGetWidth(self.activityIndicator.frame))/2.0f, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.activityIndicator.frame))/2.0f, CGRectGetWidth(self.activityIndicator.frame), CGRectGetHeight(self.activityIndicator.frame));
        [self addSubview:self.activityIndicator];
        
        _zoomScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.zoomScrollView.showsHorizontalScrollIndicator = NO;
        self.zoomScrollView.showsVerticalScrollIndicator = NO;
        self.zoomScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.zoomScrollView];
        
        _imageView = [[TAPImageView alloc] initWithFrame:self.zoomScrollView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.zoomScrollView addSubview:self.imageView];
        
        _playVideoButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 64.0f) / 2.0f, (CGRectGetHeight(self.frame) - 64.0f) / 2.0f, 64.0f, 64.0f)];
        self.playVideoButtonImageView.alpha = 0.0f;
        self.playVideoButtonImageView.layer.cornerRadius = CGRectGetHeight(self.playVideoButtonImageView.frame) / 2.0f;
        self.playVideoButtonImageView.image = [UIImage imageNamed:@"TAPIconButtonPlay" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self addSubview:self.playVideoButtonImageView];
        
        _playVideoButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 74.0f) / 2.0f, (CGRectGetHeight(self.frame) - 74.0f) / 2.0f, 74.0f, 74.0f)];
        self.playVideoButton.alpha = 0.0f;
        self.playVideoButton.userInteractionEnabled = NO;
        [self addSubview:self.playVideoButton];
    }
    
    return self;
}

#pragma mark - Custom Method
//- (void)setImageURL:(NSString *)imageURL imageLocalName:(NSString *)imageLocalName {
//    imageLocalName = [TAPUtil nullToEmptyString:imageLocalName];
//    
//    UIImage *localImage = [TAPImageView imageFromCacheWithKey:imageLocalName];
//    
//    if(localImage != nil && localImage.size.width > 0.0f && localImage.size.height > 0.0f) {
//        self.imageView.image = localImage;
//        
//        return;
//    }
//    
//    [self.imageView setImageWithURLString:imageURL];
//}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setViewStateWithType:(TAPMediaDetailPreviewViewType)type {
    if (type == TAPMediaDetailPreviewViewTypeImage) {
        self.playVideoButtonImageView.alpha = 0.0f;
        self.playVideoButton.alpha = 0.0f;
        self.playVideoButton.userInteractionEnabled = NO;

    }
    else if (type == TAPMediaDetailPreviewViewTypeVideo) {
        self.playVideoButtonImageView.alpha = 1.0f;
        self.playVideoButton.alpha = 1.0f;
        self.playVideoButton.userInteractionEnabled = YES;
    }
}

- (void)setMediaDetailPreviewViewType:(TAPMediaDetailPreviewViewType)mediaDetailPreviewViewType {
    _mediaDetailPreviewViewType = mediaDetailPreviewViewType;
    [self setViewStateWithType:self.mediaDetailPreviewViewType];
}

@end
