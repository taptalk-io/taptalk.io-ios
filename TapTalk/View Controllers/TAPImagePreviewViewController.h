//
//  TAPImagePreviewViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPImagePreviewViewControllerDelegate <NSObject>

- (void)imagePreviewDidTapSendButtonWithData:(NSArray *)dataArray;
- (void)imagePreviewCancelButtonDidTapped;
- (void)imagePreviewDidSendDataAndCompleteDismissView;

@end

@interface TAPImagePreviewViewController : TAPBaseViewController

@property (weak, nonatomic) id <TAPImagePreviewViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *participantListArray;
@property (strong, nonatomic) NSMutableArray *filteredMentionListArray;
@property (nonatomic) BOOL isNotFromPersonalRoom;

- (void)setMediaPreviewDataWithData:(TAPMediaPreviewModel *)mediaPreviewData;
- (void)setMediaPreviewDataWithArray:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
