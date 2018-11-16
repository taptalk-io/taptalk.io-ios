//
//  TAPBaseRealmModel.m
//  TapTalk
//
//  Created by Welly Kencana on 25/8/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseRealmModel.h"
#import <objc/runtime.h>

@implementation TAPBaseRealmModel
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError **)err {
    self = [self init];
//    self = [super init];
    NSArray *properties = [self getProperties];
    
    for (NSInteger counter = 0; counter < [properties count]; counter++) {
        RLMProperty *property = [properties objectAtIndex:counter];
        NSString *propertyName = property.name;
        
        if ([dict objectForKey:propertyName] == nil) {
            //null value
        }
        else {
            if (property.array) {
                //Iterate
            }
            else {
                switch (property.type) {
                    case 0:
                        //RLMPropertyTypeInt
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 1:
                        //RLMPropertyTypeBool
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 2:
                        //RLMPropertyTypeString
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 3:
                        //RLMPropertyTypeData
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 4:
                        //RLMPropertyTypeDate
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 5:
                        //RLMPropertyTypeFloat
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 6:
                        //RLMPropertyTypeDouble
                    {
                        [self setValue:[dict objectForKey:propertyName] forKey:propertyName];
                        break;
                    }
                    case 7:
                    {
                        //RLMPropertyTypeObject
                        Class typeClass = NSClassFromString(property.objectClassName);
                        
                        id newRealmModel = [[typeClass alloc] initWithDictionary:[dict objectForKey:propertyName] error:nil];
                        [self setValue:newRealmModel forKey:propertyName];
                        break;
                    }
                    case 8:
                        //RLMPropertyTypeLinkingObjects
                    {
                        break;
                    }
                    case 9:
                        //RLMPropertyTypeAny
                        //Deprecated
                    {
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
            }
        }
    }
    
    return self;
}

- (NSArray *)getProperties {
    RLMObjectSchema *schema = self.objectSchema;
    NSArray *properties = schema.properties;
    
    return properties;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *propertiesArray = [self getProperties];
    
    for (NSInteger counter = 0; counter < [propertiesArray count]; counter++) {
        RLMProperty *propertyArray = [propertiesArray objectAtIndex:counter];
        NSString *propertyName = propertyArray.name;
        if ([self valueForKey:propertyName] == nil) {
            //null value
        }
        else {
            //non-null value
            if ([[self valueForKey:propertyName] isKindOfClass:[RLMArray class]]) {
                //Object is RLMArray
                NSMutableArray *convertedArray = [NSMutableArray array];
                RLMArray *realmArray = [self valueForKey:propertyName];
                
                for(int arrayCounter = 0; arrayCounter < [realmArray count]; arrayCounter++){
                    [convertedArray addObject:[[realmArray objectAtIndex:counter] toDictionary]];
                }
                [dictionary setObject:convertedArray forKey:propertyName];
            }
            else if ([[self valueForKey:propertyName] isKindOfClass:[TAPBaseRealmModel class]]) {
                [dictionary setObject:[self[propertyName] toDictionary] forKey:propertyName];
            }
            else {
                [dictionary setObject:[self valueForKey:propertyName] forKey:propertyName];
            }
        }
    }
    
    return dictionary;
}

@end
