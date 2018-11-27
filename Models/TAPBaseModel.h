//
//  TAPBaseModel.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/8/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

@import JSONModel;

@interface TAPBaseModel : JSONModel

+ (BOOL)propertyIsOptional:(NSString*)propertyName;

@end
