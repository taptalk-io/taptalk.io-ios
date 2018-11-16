//
//  TAPContactCollectionViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 18/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactCollectionViewCell.h"

@interface TAPContactCollectionViewCell()
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) RNImageView *contactImageView;
@property (strong, nonatomic) UIImageView *removeImageView;
@property (strong, nonatomic) UILabel *contactNameLabel;
@end

@implementation TAPContactCollectionViewCell
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        _contactImageView = [[RNImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, 52.0f)];
        self.contactImageView.layer.cornerRadius = CGRectGetHeight(self.contactImageView.frame) / 2.0;
        self.contactImageView.clipsToBounds = YES;
        [self.bgView addSubview:self.contactImageView];
        
        _removeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contactImageView.frame) - 22.0f, CGRectGetMaxY(self.contactImageView.frame) - 22.0f, 22.0f, 22.0f)];
        self.removeImageView.image = [UIImage imageNamed:@"TAPIconRemove" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.bgView addSubview:self.removeImageView];
        
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.contactImageView.frame) + 8.0f, 52.0f, 13.0f)];
        self.contactNameLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        self.contactNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.contactNameLabel];
    }
    
    return self;
}

#pragma mark - Custom Method
//WK Temp
- (void)setContactCollectionViewCellWithModel:(NSString *)nantiDigantiJadiModel {
    NSString *profileImageURL = TAP_DUMMY_IMAGE_URL;
    NSString *contactName = nantiDigantiJadiModel;
    
    [self.contactImageView setImageWithURLString:profileImageURL];
    NSMutableDictionary *contactNameAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat contactNameLetterSpacing = -0.2f;
    [contactNameAttributesDictionary setObject:@(contactNameLetterSpacing) forKey:NSKernAttributeName];
    NSMutableAttributedString *contactNameAttributedString = [[NSMutableAttributedString alloc] initWithString:contactName];
    [contactNameAttributedString addAttributes:contactNameAttributesDictionary
                                         range:NSMakeRange(0, [contactName length])];
    self.contactNameLabel.attributedText = contactNameAttributedString;
}
//END WK Temp

- (void)showRemoveIcon:(BOOL)isVisible {
    if (isVisible) {
        self.removeImageView.alpha = 1.0f;
    }
    else {
        self.removeImageView.alpha = 0.0f;
    }
}

@end
