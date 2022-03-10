//
//  TAPPhotoListModel.h
//  TapTalk
//
//  Created by TapTalk.io on 24/02/22.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPPhotoListModel : TAPBaseModel
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *thumbnailImageURL;
@property (nonatomic, strong) NSString *fullsizeImageURL;
@property (nonatomic, strong) NSString *createdTime;

@end

NS_ASSUME_NONNULL_END
