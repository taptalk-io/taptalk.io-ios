//
//  TAPLoadingTableViewCell.h
//  TapTalk
//
//  Created by Cundy Sunardy on 23/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPLoadingTableViewCell : TAPBaseXIBRotatedTableViewCell
- (void)animateLoading:(BOOL)isAnimate;
@end

NS_ASSUME_NONNULL_END
