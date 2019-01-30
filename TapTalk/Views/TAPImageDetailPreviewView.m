//
//  TAPImageDetailPreviewView.m
//  TapTalk
//
//  Created by Welly Kencana on 29/1/19.
//

#import "TAPImageDetailPreviewView.h"

@implementation TAPImageDetailPreviewView

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
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.zoomScrollView addSubview:self.imageView];
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

@end
