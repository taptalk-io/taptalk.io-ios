//
//  TAPBaseXIBRotatedTableViewCell.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 06/10/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

@implementation TAPBaseXIBRotatedTableViewCell

#pragma mark - Lifecycle
+ (UINib *)cellNib {
    UINib *cellNib = [UINib nibWithNibName:[self.class description] bundle:[TAPUtil currentBundle]];
    return cellNib;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [self setTransform:CGAffineTransformMakeRotation(M_PI)];
    
    [UIView commitAnimations];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    [self setTransform:CGAffineTransformMakeRotation(M_PI)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [self setTransform:CGAffineTransformMakeRotation(M_PI)];
    
    [UIView commitAnimations];
}

#pragma mark - Custom Method

@end
