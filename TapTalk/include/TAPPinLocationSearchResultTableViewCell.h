//
//  TAPPinLocationSearchResultTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPPinLocationSearchResultTableViewCell : TAPBaseTableViewCell

- (void)setSearchResult:(NSString *)searchResult;
- (void)hideSeparatorView:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
