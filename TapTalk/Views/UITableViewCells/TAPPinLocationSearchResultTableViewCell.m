//
//  TAPPinLocationSearchResultTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPPinLocationSearchResultTableViewCell.h"

@interface TAPPinLocationSearchResultTableViewCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *searchResultLabel;
@property (strong, nonatomic) UIView *separatorView;

@end

@implementation TAPPinLocationSearchResultTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, 36.0f)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        _searchResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 36.0f)];
        self.searchResultLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        self.searchResultLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.bgView addSubview:self.searchResultLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.bgView.frame) - 1.0f, CGRectGetWidth(self.bgView.frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:@"DCDCDC"];
        [self.bgView addSubview:self.separatorView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.separatorView.backgroundColor = [TAPUtil getColor:@"DCDCDC"];
}

#pragma mark - Custom Method
- (void)setSearchResult:(NSString *)searchResult {
    self.searchResultLabel.text = searchResult;
    
    NSMutableDictionary *searchResultAttributesDictionary = [NSMutableDictionary dictionary];
    float searchResultLetterSpacing = 0.1f;
    [searchResultAttributesDictionary setObject:@(searchResultLetterSpacing) forKey:NSKernAttributeName];
    
    NSMutableAttributedString *searchResultAttributedString = [[NSMutableAttributedString alloc] initWithString:self.searchResultLabel.text];
    [searchResultAttributedString addAttributes:searchResultAttributesDictionary
                                          range:NSMakeRange(0, [self.searchResultLabel.text length])];
    self.searchResultLabel.attributedText = searchResultAttributedString;
}

- (void)hideSeparatorView:(BOOL)isHidden {
    if (isHidden) {
        self.separatorView.alpha = 0.0f;
    }
    else {
        self.separatorView.alpha = 1.0f;
    }
}
@end
