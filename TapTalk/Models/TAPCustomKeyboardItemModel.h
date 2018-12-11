//
//  TAPCustomKeyboardItemModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 29/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomKeyboardItemModel : TAPBaseModel

@property (strong, nonatomic) NSString *iconURL;
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemID;

+ (TAPCustomKeyboardItemModel *)createCustomKeyboardItemWithImageURL:(NSString *)imageURL
                                                            itemName:(NSString *)itemName
                                                              itemID:(NSString *)itemID;

+ (TAPCustomKeyboardItemModel *)createCustomKeyboardItemWithImage:(UIImage *)image
                                                         itemName:(NSString *)itemName
                                                           itemID:(NSString *)itemID;

@end

NS_ASSUME_NONNULL_END
