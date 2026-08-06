//
//  TapMessageRecipientModel.h
//  TapTalk
//
//  Created by TapTalk.io on 24/11/22.
//

#import "TAPBaseModel.h"
#import "TAPImageURLModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapMessageRecipientModel : TAPBaseModel
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *xcUserID;
@property (strong, nonatomic) NSString *fullname;
@property (nonatomic, strong) TAPImageURLModel *imageURL;
@property (strong, nonatomic) NSNumber *deliveredTime;
@property (strong, nonatomic) NSNumber *readTime;
@end

NS_ASSUME_NONNULL_END
