//
//  TAPContactLoadingTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 12/11/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPContactLoadingTableViewCell : TAPBaseTableViewCell

- (void)animateLoading:(BOOL)isAnimate;

@end

NS_ASSUME_NONNULL_END
