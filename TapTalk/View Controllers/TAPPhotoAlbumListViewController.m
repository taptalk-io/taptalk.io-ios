//
//  TAPPhotoAlbumListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPhotoAlbumListViewController.h"
#import "TAPPhotoAlbumListView.h"
#import "TAPPhotoAlbumListItemTableViewCell.h"
#import "TAPImageSelectViewController.h"

#import <Photos/Photos.h>

@interface TAPPhotoAlbumListViewController () <UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver, TAPImageSelectViewControllerDelegate>

@property (strong, nonatomic) TAPPhotoAlbumListView *photoAlbumListView;
@property (strong, nonatomic) UIBarButtonItem *leftBarButton;

//Get Camera Roll Image
@property (strong, nonatomic) PHFetchResult<PHAssetCollection *> *smartAlbums;
@property (strong, nonatomic) PHFetchResult<PHCollection *> *userCollections;
@property (strong, nonatomic) PHAssetCollection *cameraRollCollection;
@property (strong, nonatomic) PHFetchResult<PHAsset *> *cameraRollPhotos;
@property (strong, nonatomic) NSMutableArray *smartAlbumArray;
@property (strong, nonatomic) NSMutableArray *collectionArray;

- (void)closeButtonDidTapped;
- (void)fetchAlbumData;

@end

@implementation TAPPhotoAlbumListViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _photoAlbumListView = [[TAPPhotoAlbumListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    self.title = NSLocalizedStringFromTableInBundle(@"Albums", nil, [TAPUtil currentBundle], @"");
    
    [self.view addSubview:self.photoAlbumListView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
    _leftBarButton = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonDidTapped)];
    self.leftBarButton.tintColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton];
    [self.navigationItem setLeftBarButtonItem:self.leftBarButton];
    
    self.photoAlbumListView.tableView.dataSource = self;
    self.photoAlbumListView.tableView.delegate = self;
    
    _smartAlbumArray = [[NSMutableArray alloc] init];
    _collectionArray = [[NSMutableArray alloc] init];
    _selectedMediaDataArray = [[NSMutableArray alloc] init];
    _selectedImagePositionDictionary = [[NSMutableDictionary alloc] init];
    
    [self fetchAlbumData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.photoAlbumListView.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //section 0 = Smart Album | Section 1 = User Collection
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        //Smart Album
        return [self.smartAlbumArray count];
    }
    else if(section == 1) {
        //User Collection
        return [self.collectionArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellID = @"TAPPhotoAlbumListItemTableViewCell";

    TAPPhotoAlbumListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if(nil == cell) {
        cell = [[TAPPhotoAlbumListItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    if(indexPath.section == 0) {
        //Smart Album
        NSDictionary *collectionDictionary = [self.smartAlbumArray objectAtIndex:indexPath.row];
        PHAssetCollection *collection = [collectionDictionary objectForKey:@"collection"];
        PHFetchResult *assetsFetchResult = [collectionDictionary objectForKey:@"fetchResult"];
        
        NSInteger selectedCount = 0;
        NSArray *keyArray = [self.selectedImagePositionDictionary allKeys];
        for(NSString *key in keyArray) {
            NSArray *separatedKeyArray = [key componentsSeparatedByString:@"-"];
            if([[separatedKeyArray objectAtIndex:0] integerValue] == indexPath.section && [[separatedKeyArray objectAtIndex:1] integerValue] == indexPath.row) {
                selectedCount++;
            }
        }
        
        [cell setDataWithName:collection.localizedTitle total:assetsFetchResult.count selectedCount:selectedCount];
        [cell showSeparatorView:YES];

    }
    else if(indexPath.section == 1) {
        //User Collection
        NSDictionary *collectionDictionary = [self.collectionArray objectAtIndex:indexPath.row];
        PHAssetCollection *collection = [collectionDictionary objectForKey:@"collection"];
        PHFetchResult *assetsFetchResult = [collectionDictionary objectForKey:@"fetchResult"];
        
        NSInteger selectedCount = 0;
        NSArray *keyArray = [self.selectedImagePositionDictionary allKeys];
        for(NSString *key in keyArray) {
            NSArray *separatedKeyArray = [key componentsSeparatedByString:@"-"];
            if([[separatedKeyArray objectAtIndex:0] integerValue] == indexPath.section && [[separatedKeyArray objectAtIndex:1] integerValue] == indexPath.row) {
                selectedCount++;
            }
        }
        
        [cell setDataWithName:collection.localizedTitle total:assetsFetchResult.count selectedCount:selectedCount];
        [cell showSeparatorView:YES];
    }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    return view;
}

#pragma mark - Delegate
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        //smart album
        TAPImageSelectViewController *imageSelectViewController = [[TAPImageSelectViewController alloc] init];
        imageSelectViewController.delegate = self;
        imageSelectViewController.currentTotalImageData = [self.selectedMediaDataArray count];
        [imageSelectViewController setImageSelectViewControllerType:ImageSelectViewControllerTypeGalleryAlbum];
        [imageSelectViewController setImageSelectViewControllerNavigateType:ImageSelectViewControllerNavigateTypePush];
        imageSelectViewController.isNotFromPersonalRoom = self.isNotFromPersonalRoom;
        [imageSelectViewController setParticipantListArray:self.participantListArray];
        
        if (self.photoAlbumListViewControllerType == TAPPhotoAlbumListViewControllerTypeDefault) {
            [imageSelectViewController setImageSelectViewControllerContinueType:ImageSelectViewControllerContinueTypeDefault];
        }
        else if (self.photoAlbumListViewControllerType == TAPPhotoAlbumListViewControllerTypeAddMore) {
            [imageSelectViewController setImageSelectViewControllerContinueType:ImageSelectViewControllerContinueTypeAddMore];
        }
        
        NSDictionary *collectionDictionary = [self.smartAlbumArray objectAtIndex:indexPath.row];
        PHAssetCollection *collection = [collectionDictionary objectForKey:@"collection"];
        imageSelectViewController.cameraRollCollection = collection;
        
        imageSelectViewController.selectedMediaDataArray = self.selectedMediaDataArray;
        imageSelectViewController.selectedImagePositionDictionary = self.selectedImagePositionDictionary;
        imageSelectViewController.delegate = self;
        imageSelectViewController.albumIndexRow = indexPath.row;
        imageSelectViewController.albumIndexSection = indexPath.section;
        [self.navigationController pushViewController:imageSelectViewController animated:YES];
    }
    else if(indexPath.section == 1) {
        //user collection
        TAPImageSelectViewController *imageSelectViewController = [[TAPImageSelectViewController alloc] init];
        imageSelectViewController.delegate = self;
        imageSelectViewController.currentTotalImageData = [self.selectedMediaDataArray count];
        [imageSelectViewController setImageSelectViewControllerType:ImageSelectViewControllerTypeGalleryAlbum];
        [imageSelectViewController setImageSelectViewControllerNavigateType:ImageSelectViewControllerNavigateTypePush];
        imageSelectViewController.isNotFromPersonalRoom = self.isNotFromPersonalRoom;
        [imageSelectViewController setParticipantListArray:self.participantListArray];

        if (self.photoAlbumListViewControllerType == TAPPhotoAlbumListViewControllerTypeDefault) {
            [imageSelectViewController setImageSelectViewControllerContinueType:ImageSelectViewControllerContinueTypeDefault];
        }
        else if (self.photoAlbumListViewControllerType == TAPPhotoAlbumListViewControllerTypeAddMore) {
            [imageSelectViewController setImageSelectViewControllerContinueType:ImageSelectViewControllerContinueTypeAddMore];
        }
        
        NSDictionary *collectionDictionary = [self.collectionArray objectAtIndex:indexPath.row];
        PHAssetCollection *collection = [collectionDictionary objectForKey:@"collection"];
        imageSelectViewController.cameraRollCollection = collection;
        
        imageSelectViewController.selectedMediaDataArray = self.selectedMediaDataArray;
        imageSelectViewController.selectedImagePositionDictionary = self.selectedImagePositionDictionary;
        imageSelectViewController.delegate = self;
        imageSelectViewController.albumIndexRow = indexPath.row;
        imageSelectViewController.albumIndexSection = indexPath.section;
        [self.navigationController pushViewController:imageSelectViewController animated:YES];
    }
}

#pragma mark TAPImageSelectViewController
- (void)imageSelectViewControllerDidAddSelectedImage:(NSMutableArray *)selectedImageArray selectedDictionary:(NSMutableDictionary *)selectedDictionary {
    self.selectedMediaDataArray = selectedImageArray;
    self.selectedImagePositionDictionary = selectedDictionary;
}

- (void)imageSelectViewControllerDidTappedContinueButtonWithDataArray:(NSArray *)dataArray {
    if ([self.delegate respondsToSelector:@selector(photoAlbumListViewControllerSelectImageWithDataArray:)]) {
        [self.delegate photoAlbumListViewControllerSelectImageWithDataArray:dataArray];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)imageSelectViewControllerDidSendWithDataArray:(NSArray *)dataArray {
    if ([self.delegate respondsToSelector:@selector(photoAlbumListViewControllerDidFinishAndSendImageWithDataArray:)]) {
        [self.delegate photoAlbumListViewControllerDidFinishAndSendImageWithDataArray:dataArray];
    }
}

#pragma mark PHPhotoGalleryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {

}

#pragma mark - Custom Method
- (void)closeButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchAlbumData {
    
    PHFetchOptions *albumOptions = [[PHFetchOptions alloc] init];
    albumOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    self.smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:albumOptions];
    self.userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    NSMutableArray *filteredSmartAlbumArray = [NSMutableArray array];
    
    //ASSET COLLECTION SUBTYPE
    //209 - Camera Roll
    //1000000201 - Recently Deleted
    
    for (PHAssetCollection *collection in self.smartAlbums) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if(assetsFetchResult.count > 0 && (![[collection.localizedTitle lowercaseString] isEqualToString:@"camera roll"] && ![[collection.localizedTitle lowercaseString] isEqualToString:@"all photos"] && collection.assetCollectionSubtype != 209 && collection.assetCollectionSubtype != 1000000201)) {
            NSMutableDictionary *collectionDictionary = [NSMutableDictionary dictionary];
            [collectionDictionary setObject:assetsFetchResult forKey:@"fetchResult"];
            [collectionDictionary setObject:collection forKey:@"collection"];
            [filteredSmartAlbumArray addObject:collectionDictionary];
        }
        
        if([[collection.localizedTitle lowercaseString] isEqualToString:@"camera roll"] || [[collection.localizedTitle lowercaseString] isEqualToString:@"all photos"] || collection.assetCollectionSubtype == 209) {
            NSMutableDictionary *collectionDictionary = [NSMutableDictionary dictionary];
            [collectionDictionary setObject:assetsFetchResult forKey:@"fetchResult"];
            [collectionDictionary setObject:collection forKey:@"collection"];
            [filteredSmartAlbumArray insertObject:collectionDictionary atIndex:0];
        }
    }
    
    self.smartAlbumArray = filteredSmartAlbumArray;
    
    NSMutableArray *filteredCollectionArray = [NSMutableArray array];
    
    for (PHAssetCollection *collection in self.userCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if(assetsFetchResult.count > 0) {
                NSMutableDictionary *collectionDictionary = [NSMutableDictionary dictionary];
                [collectionDictionary setObject:assetsFetchResult forKey:@"fetchResult"];
                [collectionDictionary setObject:collection forKey:@"collection"];
                [filteredCollectionArray addObject:collectionDictionary];
            }
        }
    }
    self.collectionArray = filteredCollectionArray;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self.photoAlbumListView.tableView reloadData];
}

- (void)setPhotoAlbumListViewControllerType:(TAPPhotoAlbumListViewControllerType)photoAlbumListViewControllerType {
    _photoAlbumListViewControllerType = photoAlbumListViewControllerType;
}

@end
