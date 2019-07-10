//
//  TAPSystemMessageTableViewCell.m
//  TapTalk
//
//  Created by Cundy Sunardy on 12/06/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPSystemMessageTableViewCell.h"

@interface TAPSystemMessageTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

- (void)setCellStyle;

@end

@implementation TAPSystemMessageTableViewCell
#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.shadowView.backgroundColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSystemMessageBackgroundShadow] colorWithAlphaComponent:0.4f];
    self.shadowView.layer.cornerRadius = 8.0f;
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.shadowView.layer.shadowOpacity = 1.0f;
    self.shadowView.layer.masksToBounds = NO;
    
    self.containerView.layer.cornerRadius = 8.0f;
    
    [self setCellStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (void)setCellStyle {
    
    UIFont *systemMessageFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSystemMessageBody];
    UIColor *systemMessageColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSystemMessageBody];
    self.contentLabel.textColor = systemMessageColor;
    self.contentLabel.font = systemMessageFont;
    
    self.shadowView.backgroundColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSystemMessageBackgroundShadow] colorWithAlphaComponent:0.4f];
    self.containerView.backgroundColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSystemMessageBackground] colorWithAlphaComponent:0.82f];
}

- (void)setMessage:(TAPMessageModel *)message {
    
    NSString *contentString = message.body;
    
    NSString *targetAction = message.action;
    TAPGroupTargetModel *groupTarget = message.target;
    NSString *targetName = groupTarget.targetName;
    targetName = [TAPUtil nullToEmptyString:targetName];
    
    if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        contentString = [contentString stringByReplacingOccurrencesOfString:@"{{sender}}" withString:@"You"];

    }
    else {
        contentString = [contentString stringByReplacingOccurrencesOfString:@"{{sender}}" withString:message.user.fullname];
    }
    
    if (groupTarget != nil) {
        if ([groupTarget.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            contentString = [contentString stringByReplacingOccurrencesOfString:@"{{target}}" withString:@"you"];
            
        }
        else {
            contentString = [contentString stringByReplacingOccurrencesOfString:@"{{target}}" withString:targetName];
        }
    }

    self.contentLabel.text = contentString;

}


@end
