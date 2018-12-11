//
//  TAPBaseGeneralBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 28/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseGeneralBubbleTableViewCell.h"

@implementation TAPBaseGeneralBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (void)setMessage:(TAPMessageModel *)message {
    
}

- (void)receiveSentEvent {
    
}

- (void)receiveDeliveredEvent {
    
}

- (void)receiveReadEvent {
    
}



@end
