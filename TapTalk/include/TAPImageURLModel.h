//
//  TAPImageURLModel.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 4/12/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

@interface TAPImageURLModel : TAPBaseModel

@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *fullsize;

@end
