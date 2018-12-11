//
//  TAPProfileView.h
//  TapTalk
//
//  Created by Welly Kencana on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPProfileView : TAPBaseView

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) RNImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *navigationNameLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *navigationBackButton;

@property (nonatomic) CGFloat nameLabelHeight;
@property (nonatomic) CGFloat nameLabelBottomPadding;
@property (nonatomic) CGFloat nameLabelYPosition;
@property (nonatomic) CGFloat navigationNameLabelHeight;
@property (nonatomic) CGFloat navigationNameLabelBottomPadding;
@property (nonatomic) CGFloat navigationNameLabelYPosition;
@property (nonatomic) CGFloat navigationBarHeight;

@end

NS_ASSUME_NONNULL_END
