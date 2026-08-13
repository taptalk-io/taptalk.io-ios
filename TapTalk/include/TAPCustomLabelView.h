//
//  TAPCustomLabelView.h
//  TapTalk
//
//  Created by TapTalk.io on 17/02/22.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,TAPCustomLabelViewType) {
    TAPCustomLabelViewTypeAccountDetailField = 0,
};

@interface TAPCustomLabelView : UIView
@property (strong, nonatomic) UILabel *infoDescriptionLabel;

- (void)showSeparatorView:(BOOL)isShowed;
- (void) setAccountDetailFieldString:(NSString *)title description:(NSString *)description;
- (void)setInfoDesciption:(NSString *)descp;
@end

