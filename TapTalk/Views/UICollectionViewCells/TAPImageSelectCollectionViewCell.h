//
//  TAPImageSelectCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

@interface TAPImageSelectCollectionViewCell : TAPBaseCollectionViewCell

@property (strong, nonatomic) TAPImageView *imageView;
@property (strong, nonatomic) UIImageView *checklistImageView;

- (void)setCellWithImageString:(NSString *)imageURL;
- (void)setCellWithImage:(UIImage *)image;
- (void)setCellAsSelected:(BOOL)isSelected;

@end
