//
//  TAPKeyboardTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPKeyboardTableViewCell.h"

@interface TAPKeyboardTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *stringLabel;
@property (strong, nonatomic) IBOutlet UILabel *emoticonLabel;

@end

@implementation TAPKeyboardTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark - Custom Method
- (void)setKeyboardCellWithType:(TAPKeyboardTableViewCellType)type {
    NSString *titleString = @"";
    NSString *emoticonString = @"";
    
    if (type == TAPKeyboardTableViewCellTypePriceList) {
        titleString = NSLocalizedString(@"See pricelist", @"");
        emoticonString = @"👀";
    }
    else if (type == TAPKeyboardTableViewCellTypeExpertNotes) {
        titleString = NSLocalizedString(@"Read expert’s notes", @"");
        emoticonString = @"🔍";
    }
    else if (type == TAPKeyboardTableViewCellTypeSendService) {
        titleString = NSLocalizedString(@"Send services", @"");
        emoticonString = @"💌";
    }
    else if (type == TAPKeyboardTableViewCellTypeCreateOrderCard) {
        titleString = NSLocalizedString(@"Create order card", @"");
        emoticonString = @"✏️";
    }
    
    self.stringLabel.text = titleString;
    self.emoticonLabel.text = emoticonString;
}

@end
