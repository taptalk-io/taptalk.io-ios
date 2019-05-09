//
//  TAPSearchViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPSearchViewControllerDelegate <NSObject>

- (void)searchViewControllerDidTappedSearchCancelButton;

@end

@interface TAPSearchViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPSearchViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
