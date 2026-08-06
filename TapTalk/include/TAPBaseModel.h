//
//  TAPBaseModel.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/8/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TapJSONModel.h"

@interface TAPBaseModel : TapJSONModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName;

@end
