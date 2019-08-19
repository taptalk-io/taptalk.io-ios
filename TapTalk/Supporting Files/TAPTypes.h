//
//  TAPTypes.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#ifndef TAPTypes_h
#define TAPTypes_h

typedef NS_ENUM(NSInteger, TapTalkInstanceState) {
    TapTalkInstanceStateActive, //Active state triggered when application enter foreground
    TapTalkInstanceStateInactive //Inactive state triggered when application terminated by os, or crash, or when in background and have finished background sequence
};

typedef NS_ENUM(NSInteger, TapTalkImplentationType) {
    TapTalkImplentationTypeUI,
    TapTalkImplentationTypeCore,
    TapTalkImplentationTypeCombine
};

typedef NS_ENUM(NSInteger, TAPChatMessageType) {
    //First Digit
    //1 for Standard Chat Bubble
    //2 for Commerce Chat Bubble
    //3 for User Customized Chat Bubble
    //9 for System Message
    
    TAPChatMessageTypeText = 1001,
    TAPChatMessageTypeImage = 1002,
    TAPChatMessageTypeVideo = 1003,
    TAPChatMessageTypeFile = 1004,
    TAPChatMessageTypeLocation = 1005,
    TAPChatMessageTypeContact = 1006,
    TAPChatMessageTypeSticker = 1007,
    
    TAPChatMessageTypeProduct = 2001,
    TAPChatMessageTypeCategory = 2002,
    TAPChatMessageTypePaymentConfirmation = 2004,
    
    TAPChatMessageTypeOrderCard = 3001,
    
    TAPChatMessageTypeSystemMessage = 9001,
    TAPChatMessageTypeUnreadMessageIdentifier = 9002,
    
};

#endif /* TAPTypes_h */
