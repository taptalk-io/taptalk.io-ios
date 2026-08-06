//
//  TAPImageSelectView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPImageSelectView : TAPBaseView

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UILabel *itemNumberLabel;
@property (strong, nonatomic) UIView *itemNumberView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

- (void)startLoadingAnimation;
- (void)endLoadingAnimation;

@end
