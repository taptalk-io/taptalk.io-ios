//
//  TAPBaseTableView.m
//  TapTalk
//
//  Created by Kevin on 7/19/22.
//

#import "TAPBaseTableView.h"

@implementation TAPBaseTableView

- (instancetype)init {
    if ((self = [super init])) {
        [self clearSectionHeaderTopPadding];
        [self hideTopEdgeEffect];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self clearSectionHeaderTopPadding];
        [self hideTopEdgeEffect];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self clearSectionHeaderTopPadding];
        [self hideTopEdgeEffect];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ((self = [super initWithFrame:frame style:style])) {
        [self clearSectionHeaderTopPadding];
        [self hideTopEdgeEffect];
    }
    return self;
}

- (void)clearSectionHeaderTopPadding {
    if (@available(iOS 15.0, *)) {
        [self setSectionHeaderTopPadding:0.0f];
        self.verticalScrollIndicatorInsets = UIEdgeInsetsMake(CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN);
    }
}

- (void)hideTopEdgeEffect {
    if (@available(iOS 26.0, *)) {
        [self.topEdgeEffect setHidden:YES];
    }
}

@end
