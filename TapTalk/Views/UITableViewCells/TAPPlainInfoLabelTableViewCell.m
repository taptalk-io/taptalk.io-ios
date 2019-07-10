//
//  TAPPlainInfoLabelTableViewCell.m
//  TapTalk
//
//  Created by Cundy Sunardy on 07/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPPlainInfoLabelTableViewCell.h"

@interface TAPPlainInfoLabelTableViewCell()

@property (strong, nonatomic) UILabel *infoLabel;

@end

@implementation TAPPlainInfoLabelTableViewCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, (68.0f - 20.0f)/2, CGRectGetWidth([UIScreen mainScreen].bounds) - 32.0f, 20.0f)];
        self.infoLabel.font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD size:16.0f];
        self.infoLabel.textColor = [TAPUtil getColor:@"9B9B9B"];
        //CS NOTE TO DOM
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:self.infoLabel];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Custom Method
- (void)setInfoLabelWithString:(NSString *)infoString {
    self.infoLabel.text = infoString;
}

@end
