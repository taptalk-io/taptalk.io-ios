//
//  TAPCreateGroupSubjectView.h
//  TapTalk
//
//  Created by Welly Kencana on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCreateGroupSubjectView : TAPBaseView
@property (strong, nonatomic) UIView *selectedContactsView;
@property (strong, nonatomic) UILabel *selectedContactsTitleLabel;
@property (strong, nonatomic) UICollectionView *selectedContactsCollectionView;

@property (strong, nonatomic) UIScrollView *bgScrollView;
@property (strong, nonatomic) UIButton *groupPictureButton;

@property (strong, nonatomic) UILabel *placeHolderLabel;
@property (strong, nonatomic) UITextField *groupNameTextField;

@property (strong, nonatomic) UIButton *createButton;

- (void)setGroupPictureImageViewWithImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
