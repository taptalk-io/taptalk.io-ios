//
//  TAPImagePreviewView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPImagePreviewView : TAPBaseView

@property (strong, nonatomic) UICollectionView *imagePreviewCollectionView;
@property (strong, nonatomic) UICollectionView *thumbnailCollectionView;

@end

NS_ASSUME_NONNULL_END
