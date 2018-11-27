//
//  TAPSearchBarView.h
//  TapTalk
//
//  Created by Welly Kencana on 3/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPSearchBarView : UIView
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) NSString *customPlaceHolderString;
@end

NS_ASSUME_NONNULL_END
