//
//  TAPQuoteModel.m
//  TapTalk
//
//  Created by Cundy Sunardy on 26/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPQuoteModel.h"

@implementation TAPQuoteModel

+ (instancetype)constructFromMessageModel:(TAPMessageModel *)message {
    TAPQuoteModel *quote = [TAPQuoteModel new];
    
    if (message.type == TAPChatMessageTypeFile) {
        NSString *fileName = [message.data objectForKey:@"fileName"];
        fileName = [TAPUtil nullToEmptyString:fileName];
        
        NSString *fileExtension  = [[fileName pathExtension] uppercaseString];
        
        fileName = [fileName stringByDeletingPathExtension];
        
        if ([fileExtension isEqualToString:@""]) {
            fileExtension = [message.data objectForKey:@"mediaType"];
            fileExtension = [TAPUtil nullToEmptyString:fileExtension];
            fileExtension = [fileExtension lastPathComponent];
            fileExtension = [fileExtension uppercaseString];
        }
        
        NSNumber *sizeData = [message.data objectForKey:@"size"];
        
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[sizeData integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
        
        NSString *fileDescription;
        
        if (sizeData != nil && sizeData.longValue > 0L) {
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
            fileDescription = [NSString stringWithFormat:@"%@ %@", fileSize, fileExtension];
        }
        else {
            fileDescription = fileExtension;
        }
        
        quote.title = fileName;
        quote.content = fileDescription;
        
        quote.fileType = @"file";
    }
    else {
        quote.title = message.user.fullname;
        quote.content = message.body;
    }
    
    quote.fileID = [TAPUtil nullToEmptyString:[message.data objectForKey:@"fileID"]];
    
    quote.imageURL = [TAPUtil nullToEmptyString:[message.data objectForKey:@"url"]];
    if ([quote.imageURL isEqualToString:@""]) {
        quote.imageURL = [TAPUtil nullToEmptyString:[message.data objectForKey:@"fileURL"]];
    }
    else if ([quote.imageURL isEqualToString:@""]) {
        quote.imageURL = [TAPUtil nullToEmptyString:[message.data objectForKey:@"imageURL"]];
    }
    
    if (message.type == TAPChatMessageTypeImage) {
        quote.fileType = @"image";
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        quote.fileType = @"video";
    }
    
    return quote;
}

@end
