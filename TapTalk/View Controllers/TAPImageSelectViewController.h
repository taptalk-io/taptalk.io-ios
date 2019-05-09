//
//  TAPImageSelectViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, ImageSelectViewControllerNavigateType) {
    ImageSelectViewControllerNavigateTypePush,
    ImageSelectViewControllerNavigateTypePresent
};

typedef NS_ENUM(NSInteger, ImageSelectViewControllerType) {
    ImageSelectViewControllerTypeGallery,
    ImageSelectViewControllerTypeGalleryAlbum,
};

typedef NS_ENUM(NSInteger, ImageSelectViewControllerContinueType) {
    ImageSelectViewControllerContinueTypeDefault,
    ImageSelectViewControllerContinueTypeAddMore
};

@protocol TAPImageSelectViewControllerDelegate <NSObject>

@optional
- (void)imageSelectViewControllerDidTappedContinueButtonWithDataArray:(NSArray *)dataArray firstLoginInstagram:(BOOL)isFirstLogin;
- (void)imageSelectViewControllerDidTappedBackButton;
- (void)imageSelectViewControllerDidAddSelectedImage:(NSMutableArray *)selectedImageArray selectedDictionary:(NSMutableDictionary *)selectedDictionary;
- (void)imageSelectViewControllerDidTappedContinueButtonWithDataArray:(NSArray *)dataArray;
- (void)imageSelectViewControllerDidSendWithDataArray:(NSArray *)dataArray;

@end

@interface TAPImageSelectViewController : TAPBaseViewController

@property (weak, nonatomic) id <TAPImageSelectViewControllerDelegate> delegate;
@property (nonatomic) ImageSelectViewControllerNavigateType imageSelectViewControllerNavigateType;
@property (nonatomic) ImageSelectViewControllerType imageSelectViewControllerType;
@property (nonatomic) ImageSelectViewControllerContinueType imageSelectViewControllerContinueType;
@property (nonatomic) NSInteger currentTotalImageData;
@property (strong, nonatomic) NSMutableArray *selectedMediaDataArray;
@property (strong, nonatomic) PHAssetCollection *cameraRollCollection;
@property (nonatomic) NSInteger albumIndexRow; //used in ImageSelectViewControllerTypeGalleryAlbum
@property (nonatomic) NSInteger albumIndexSection; //used in ImageSelectViewControllerTypeGalleryAlbum
@property (strong, nonatomic) NSMutableDictionary *selectedImagePositionDictionary; //used in ImageSelectViewControllerTypeGalleryAlbum

- (void)setImageSelectViewControllerNavigateType:(ImageSelectViewControllerNavigateType)imageSelectViewControllerNavigateType;
- (void)setImageSelectViewControllerType:(ImageSelectViewControllerType)imageSelectViewControllerType;
- (void)setImageSelectViewControllerContinueType:(ImageSelectViewControllerContinueType)imageSelectViewControllerContinueType;

@end
