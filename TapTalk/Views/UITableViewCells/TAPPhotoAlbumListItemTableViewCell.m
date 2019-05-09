//
//  TAPPhotoAlbumListItemTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPhotoAlbumListItemTableViewCell.h"

@interface TAPPhotoAlbumListItemTableViewCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UILabel *selectedCountLabel;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIView *selectedCountView;

@end

@implementation TAPPhotoAlbumListItemTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat cellHeight = 44.0f;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 3.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f - 100.0f, 23.0f)];
        self.nameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.nameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:15.0f];
        [self.contentView addSubview:self.nameLabel];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.nameLabel.frame) - 4.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f - 100.0f, 18.0f)];
        self.countLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
        self.countLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:11.0f];
        [self.contentView addSubview:self.countLabel];
        
        _separatorView =  [[UIView alloc] initWithFrame:CGRectMake(0.0f, cellHeight - 1.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:@"E5E5E5"];
        [self.contentView addSubview:self.separatorView];
        
        _selectedCountView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 15.0f - 16.0f, (cellHeight - 15.0f)/2, 15.0f, 15.0f)];
        self.selectedCountView.backgroundColor = [TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1];
        self.selectedCountView.layer.cornerRadius = CGRectGetWidth(self.selectedCountView.frame)/2.0f;
        [self.contentView addSubview:self.selectedCountView];
        
        _selectedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
        self.selectedCountLabel.textColor = [UIColor whiteColor];
        self.selectedCountLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:10.0f];
        self.selectedCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.selectedCountView addSubview:self.selectedCountLabel];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = @"";
    self.separatorView.alpha = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (void)showSeparatorView:(BOOL)show {
    if(show) {
        self.separatorView.alpha = 1.0f;
    }
    else {
        self.separatorView.alpha = 0.0f;
    }
}

- (void)setDataWithName:(NSString *)name total:(NSInteger)total selectedCount:(NSInteger)selectedCount {
    self.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)total];
    
    if(selectedCount > 0) {
        self.selectedCountView.alpha = 1.0f;
        self.selectedCountLabel.text = [NSString stringWithFormat:@"%ld", (long)selectedCount];
    }
    else {
        self.selectedCountView.alpha = 0.0f;
        self.selectedCountLabel.text = @"";
    }
}

@end
