//
//  TAPCustomKeyboardItemModel.m
//  TapTalk
//
//  Created by Cundy Sunardy on 29/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomKeyboardItemModel.h"

@implementation TAPCustomKeyboardItemModel

+ (TAPCustomKeyboardItemModel *)createCustomKeyboardItemWithImageURL:(NSString *)imageURL
                                                            itemName:(NSString *)itemName
                                                              itemID:(NSString *)itemID {
    
    TAPCustomKeyboardItemModel *tapCustomKeyboardItemModel = [TAPCustomKeyboardItemModel new];
    tapCustomKeyboardItemModel.iconURL = imageURL;
    tapCustomKeyboardItemModel.iconImage = nil;
    tapCustomKeyboardItemModel.itemName = itemName;
    tapCustomKeyboardItemModel.itemID = itemID;
    return tapCustomKeyboardItemModel;
}

+ (TAPCustomKeyboardItemModel *)createCustomKeyboardItemWithImage:(UIImage *)image
                                                         itemName:(NSString *)itemName
                                                           itemID:(NSString *)itemID {
    TAPCustomKeyboardItemModel *tapCustomKeyboardItemModel = [TAPCustomKeyboardItemModel new];
    tapCustomKeyboardItemModel.iconURL = @"";
    tapCustomKeyboardItemModel.iconImage = image;
    tapCustomKeyboardItemModel.itemName = itemName;
    tapCustomKeyboardItemModel.itemID = itemID;
    return tapCustomKeyboardItemModel;
}

@end
