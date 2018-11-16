//
//  TAPRecentSearchTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 15/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPRecentSearchTableViewCellDelegate <NSObject>

//- (void)recentSearchTableViewCellDeleteButtonDidTappedAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TAPRecentSearchTableViewCell : TAPBaseTableViewCell

//@property (weak, nonatomic) id<TAPRecentSearchTableViewCellDelegate> delegate;
//@property (strong, nonatomic) NSIndexPath *cellIndexPath;

//- (void)setRecentSearchTableViewCellWithString:(NSString *)recentSearchString;

@end

NS_ASSUME_NONNULL_END
