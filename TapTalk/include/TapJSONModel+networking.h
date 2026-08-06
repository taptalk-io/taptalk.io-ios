//
//  JSONModel+networking.h
//  JSONModel
//

#import "TapJSONModel.h"
#import "TapJSONHTTPClient.h"

typedef void (^JSONModelBlock)(id model, TapJSONModelError *err) DEPRECATED_ATTRIBUTE;

@interface TapJSONModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(TapJSONModel *)post toURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
