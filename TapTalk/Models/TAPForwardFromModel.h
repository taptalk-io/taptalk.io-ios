//
//  TAPForwardFromModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 09/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPForwardFromModel : TAPBaseModel

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *xcUserID;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *localID;

@end

NS_ASSUME_NONNULL_END
