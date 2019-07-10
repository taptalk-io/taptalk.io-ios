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
@property (strong, nonatomic) UIImageView *arrowImageView;

@end

@implementation TAPPhotoAlbumListItemTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat cellHeight = 70.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 12.0f - 4.0f - 20.0f - 16.0f;
        
        UIFont *albumNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumNameLabel];
        UIColor *albumNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorAlbumNameLabel];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, nameLabelWidth, 22.0f)];
        self.nameLabel.textColor = albumNameLabelColor;
        self.nameLabel.font = albumNameLabelFont;
        [self.contentView addSubview:self.nameLabel];

        UIFont *albumCountLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumCountLabel];
        UIColor *albumCountLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorAlbumCountLabel];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f - 100.0f, 16.0f)];
        self.countLabel.textColor = albumCountLabelColor;
        self.countLabel.font = albumCountLabelFont;
        [self.contentView addSubview:self.countLabel];
        
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 20.0f, (cellHeight - 20.0f) / 2.0f, 20.0f, 20.0f)];
        self.arrowImageView.image = [UIImage imageNamed:@"TAPIconRightArrowCell" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.contentView addSubview:self.arrowImageView];
        
        _selectedCountView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.arrowImageView.frame) - 4.0f, (cellHeight - 20.0f) / 2.0f, 0.0f, 20.0f)];
        self.selectedCountView.clipsToBounds = YES;
        self.selectedCountView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
        self.selectedCountView.layer.cornerRadius = CGRectGetHeight(self.selectedCountView.frame) / 2.0f;
        [self.contentView addSubview:self.selectedCountView];
        
        UIFont *selectedCountLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontUnreadBadgeLabel];
        UIColor *selectedCountLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorUnreadBadgeLabel];
        _selectedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0f, 3.0f, 0.0f, 13.0f)];
        self.selectedCountLabel.textColor = selectedCountLabelColor;
        self.selectedCountLabel.textAlignment = NSTextAlignmentCenter;
        self.selectedCountLabel.font = selectedCountLabelFont;
        [self.selectedCountView addSubview:self.selectedCountLabel];
        
        _separatorView =  [[UIView alloc] initWithFrame:CGRectMake(0.0f, cellHeight - 1.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.contentView addSubview:self.separatorView];
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
    
    
    CGSize selectedCountLabelSize = [self.selectedCountLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.selectedCountLabel.frame))];
    
    CGFloat selectedCountViewWidth = CGRectGetWidth(self.selectedCountLabel.frame) + 7.0f + 7.0f;
    if (selectedCountViewWidth < CGRectGetHeight(self.selectedCountView.frame)) {
        selectedCountViewWidth = CGRectGetHeight(self.selectedCountView.frame);
    }
    
    CGFloat selectedCountMessageLabelXPosition = (selectedCountViewWidth - selectedCountLabelSize.width) / 2.0f;
    self.selectedCountLabel.frame = CGRectMake(selectedCountMessageLabelXPosition, CGRectGetMinY(self.selectedCountLabel.frame), selectedCountLabelSize.width, CGRectGetHeight(self.selectedCountLabel.frame));
    
    self.selectedCountView.frame = CGRectMake(CGRectGetMinX(self.arrowImageView.frame) - 4.0f - selectedCountViewWidth, CGRectGetMinY(self.selectedCountView.frame), selectedCountViewWidth, CGRectGetHeight(self.selectedCountView.frame));
    
    CGFloat nameLabelWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 12.0f - 4.0f - 20.0f - 16.0f - CGRectGetWidth(self.selectedCountView.frame);
    self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMinY(self.nameLabel.frame), nameLabelWidth, CGRectGetHeight(self.nameLabel.frame));
    self.countLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), nameLabelWidth, CGRectGetHeight(self.countLabel.frame));
}

@end
