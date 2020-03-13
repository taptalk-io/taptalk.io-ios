//
//  TAPStyleManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/06/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPStyleManager.h"

@interface TAPStyleManager ()

@property (strong, nonatomic) NSMutableDictionary *defaultColorDictionary;
@property (strong, nonatomic) NSMutableDictionary *textColorDictionary;
@property (strong, nonatomic) NSMutableDictionary *componentColorDictionary;
@property (strong, nonatomic) NSMutableDictionary *defaultFontDictionary;
@property (strong, nonatomic) NSMutableDictionary *componentFontDictionary;

- (UIFont *)retrieveFontDataWithIdentifier:(TAPDefaultFont)defaultFontType;
- (UIFont *)retrieveComponentFontDataWithIdentifier:(TAPComponentFont)componentFontType;
- (UIColor *)retrieveColorDataWithIdentifier:(TAPDefaultColor)defaultColorType;
- (UIColor *)retrieveTextColorDataWithIdentifier:(TAPTextColor)textColorType;
- (UIColor *)retrieveComponentColorDataWithIdentifier:(TAPComponentColor)componentType;

@end

@implementation TAPStyleManager
#pragma mark - Lifecycle
+ (TAPStyleManager *)sharedManager {
    static TAPStyleManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[TAPStyleManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _defaultColorDictionary = [[NSMutableDictionary alloc] init];
        _defaultFontDictionary = [[NSMutableDictionary alloc] init];
        _textColorDictionary = [[NSMutableDictionary alloc] init];
        _componentColorDictionary = [[NSMutableDictionary alloc] init];
        _componentFontDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)clearStyleManagerData {
    [self.defaultColorDictionary removeAllObjects];
    [self.defaultFontDictionary removeAllObjects];
    [self.textColorDictionary removeAllObjects];
    [self.componentColorDictionary removeAllObjects];
    [self.componentFontDictionary removeAllObjects];
}


- (void)setDefaultFont:(UIFont *)font forType:(TAPDefaultFont)defaultFontType {
    [self.defaultFontDictionary setObject:font forKey:[NSNumber numberWithInteger:defaultFontType]];
}

- (void)setComponentFont:(UIFont *)font forType:(TAPComponentFont)componentFontType {
    [self.componentFontDictionary setObject:font forKey:[NSNumber numberWithInteger:componentFontType]];
}

- (void)setDefaultColor:(UIColor *)color forType:(TAPDefaultColor)defaultColorType {
    [self.defaultColorDictionary setObject:color forKey:[NSNumber numberWithInteger:defaultColorType]];
}

- (void)setTextColor:(UIColor *)color forType:(TAPTextColor)textColorType {
    [self.textColorDictionary setObject:color forKey:[NSNumber numberWithInteger:textColorType]];
}

- (void)setComponentColor:(UIColor *)color forType:(TAPComponentColor)componentColorType {
    [self.componentColorDictionary setObject:color forKey:[NSNumber numberWithInteger:componentColorType]];
}

- (UIFont *)getDefaultFontForType:(TAPDefaultFont)defaultFontType {
    UIFont *font = [[TAPStyleManager sharedManager] retrieveFontDataWithIdentifier:defaultFontType];
    return font;
}

- (UIFont *)getComponentFontForType:(TAPComponentFont)componentFontType {
    UIFont *font = [[TAPStyleManager sharedManager] retrieveComponentFontDataWithIdentifier:componentFontType];
    return font;
}

- (UIColor *)getDefaultColorForType:(TAPDefaultColor)defaultColorType {
    UIColor *color = [[TAPStyleManager sharedManager] retrieveColorDataWithIdentifier:defaultColorType];
    return color;
}

- (UIColor *)getTextColorForType:(TAPTextColor)textColorType {
    UIColor *color = [[TAPStyleManager sharedManager] retrieveTextColorDataWithIdentifier:textColorType];
    return color;
}

- (UIColor *)getComponentColorForType:(TAPComponentColor)componentType {
    UIColor *color = [[TAPStyleManager sharedManager] retrieveComponentColorDataWithIdentifier:componentType];
    return color;
}

- (UIFont *)retrieveFontDataWithIdentifier:(TAPDefaultFont)defaultFontType {
    UIFont *obtainedFont = [self.defaultFontDictionary objectForKey:[NSNumber numberWithInteger:defaultFontType]];
    if (obtainedFont != nil) {
        return obtainedFont;
    }
    
    switch (defaultFontType) {
        case TAPDefaultFontItalic:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_ITALIC size:[UIFont systemFontSize]];
            return font;
            break;
        }
        case TAPDefaultFontRegular:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:[UIFont systemFontSize]];
            return font;
            break;
        }
        case TAPDefaultFontMedium:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_MEDIUM size:[UIFont systemFontSize]];
            return font;
            break;
        }
        case TAPDefaultFontBold:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD size:[UIFont systemFontSize]];
            return font;
            break;
        }
        default:
        {
            //Set default font to prevent crash
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:[UIFont systemFontSize]];
            return font;
            break;
        }
    }
}

- (UIFont *)retrieveComponentFontDataWithIdentifier:(TAPComponentFont)componentFontType {
    UIFont *obtainedFont = [self.componentFontDictionary objectForKey:[NSNumber numberWithInteger:componentFontType]];
    if (obtainedFont != nil) {
        return obtainedFont;
    }
    
    switch (componentFontType) {
        case TAPComponentFontTitleLabel:
        {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_TITLE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontNavigationBarTitleLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_NAVIGATION_BAR_TITLE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontNavigationBarButtonLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_NAVIGATION_BAR_BUTTON_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontFormLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
            font = [font fontWithSize:TAP_FORM_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontFormDescriptionLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_FORM_DESCRIPTION_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontFormErrorInfoLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_FORM_ERROR_INFO_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontFormTextField:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_FORM_TEXTFIELD_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontFormTextFieldPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_FORM_TEXTFIELD_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontClickableLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CLICKABLE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontClickableDestructiveLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CLICKABLE_DESTRUCTIVE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontButtonLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_BUTTON_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontInfoLabelTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_INFO_LABEL_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontInfoLabelSubtitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_INFO_LABEL_SUBTITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontInfoLabelSubtitleBold:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_INFO_LABEL_SUBTITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontInfoLabelBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_INFO_LABEL_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontInfoLabelBodyBold:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_INFO_LABEL_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontKeyboardAccessoryLabel:
        {
        
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_KEYBOARD_ACCESSORY_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontPopupLoadingLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_POPUP_LOADING_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchConnectionLostTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
            font = [font fontWithSize:TAP_SEARCH_CONNECTION_LOST_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchConnectionLostDescription:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_SEARCH_CONNECTION_LOST_DESCRIPTION_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontUnreadBadgeLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_UNREAD_BADGE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchBarText:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_SEARCHBAR_TEXT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchBarTextPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_SEARCHBAR_TEXT_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchBarTextCancelButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_SEARCHBAR_TEXT_CANCEL_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontPopupDialogTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_POPUP_DIALOG_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontPopupDialogBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_POPUP_DIALOG_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontPopupDialogButtonTextPrimary:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_POPUP_DIALOG_BUTTON_TEXT_PRIMARY_SUCCESS_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontPopupDialogButtonTextSecondary:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_POPUP_DIALOG_BUTTON_TEXT_SECONDARY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontActionSheetDefaultLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ACTION_SHEET_DEFAULT_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontActionSheetDestructiveLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ACTION_SHEET_DESTRUCTIVE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontActionSheetCancelButtonLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_ACTION_SHEET_CANCEL_BUTTON_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontTableViewSectionHeaderLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_TABLEVIEW_SECTION_HEADER_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontContactListName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CONTACT_LIST_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontContactListNameHighlighted:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CONTACT_LIST_NAME_HIGHLIGHTED_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontContactListUsername:
        {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CONTACT_LIST_USERNAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaListInfoLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_MEDIA_LIST_INFO_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_ROOM_LIST_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListNameHighlighted:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_ROOM_LIST_NAME_HIGHLIGHTED_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListMessage:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ROOM_LIST_MESSAGE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListMessageHighlighted:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ROOM_LIST_MESSAGE_HIGHLIGHTED_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListTime:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ROOM_LIST_TIME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontGroupRoomListSenderName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_GROUP_ROOM_LIST_SENDER_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomListUnreadBadgeLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_ROOM_LIST_UNREAD_BADGE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontNewChatMenuLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_NEW_CHAT_MENU_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatProfileRoomNameLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CHAT_PROFILE_ROOM_NAME_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatProfileMenuLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CHAT_PROFILE_MENU_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatProfileMenuDestructiveLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CHAT_PROFILE_MENU_DESTRUCTIVE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchNewContactResultName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_SEARCH_NEW_CONTACT_RESULT_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSearchNewContactResultUsername:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_SEARCH_NEW_CONTACT_RESULT_USERNAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontAlbumNameLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_ALBUM_NAME_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontAlbumCountLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_ALBUM_COUNT_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontGalleryPickerCancelButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_GALLERY_PICKER_CANCEL_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontGalleryPickerContinueButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_GALLERY_PICKER_CONTINUE_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatRoomNameLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CHAT_ROOM_NAME_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatRoomStatusLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CHAT_ROOM_STATUS_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatComposerTextField:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CHAT_COMPOSER_TEXTFIELD_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatComposerTextFieldPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CHAT_COMPOSER_TEXTFIELD_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontCustomKeyboardItemLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CUSTOM_KEYBOARD_ITEM_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontQuoteLayoutTitleLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_QUOTE_LAYOUT_TITLE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontQuoteLayoutContentLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_QUOTE_LAYOUT_CONTENT_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleMessageBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_MESSAGE_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleMessageBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_MESSAGE_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleMessageBodyURL:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_MESSAGE_BODY_URL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleMessageBodyURL:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_MESSAGE_BODY_URL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleMessageBodyURLHighlighted:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_MESSAGE_BODY_URL_HIGHLIGHTED_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleMessageBodyURLHighlighted:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_DELETED_MESSAGE_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleDeletedMessageBody: {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_DELETED_MESSAGE_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleDeletedMessageBody: {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_MESSAGE_BODY_URL_HIGHLIGHTED_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleQuoteTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_QUOTE_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleQuoteTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_QUOTE_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightBubbleQuoteContent:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_BUBBLE_QUOTE_CONTENT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleQuoteContent:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_QUOTE_CONTENT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightFileBubbleName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_RIGHT_FILE_BUBBLE_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftFileBubbleName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LEFT_FILE_BUBBLE_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRightFileBubbleInfo:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_RIGHT_FILE_BUBBLE_INFO_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftFileBubbleInfo:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LEFT_FILE_BUBBLE_INFO_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLeftBubbleSenderName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LEFT_BUBBLE_SENDER_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontBubbleMessageStatus:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_BUBBLE_MESSAGE_STATUS_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontBubbleMediaInfo:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_BUBBLE_MEDIA_INFO_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSystemMessageBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
            font = [font fontWithSize:TAP_SYSTEM_MESSAGE_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontChatRoomUnreadBadge:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CHAT_ROOM_UNREAD_BADGE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontUnreadMessageIdentifier:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_UNREAD_MESSAGE_IDENTIFIER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontUnreadMessageButtonLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
            font = [font fontWithSize:TAP_UNREAD_MESSAGE_BUTTON_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontDeletedChatRoomInfoTitleLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_DELETED_CHAT_ROOM_INFO_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontDeletedChatRoomInfoContentLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_DELETED_CHAT_ROOM_INFO_CONTENT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerTextField:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LOCATION_PICKER_TEXTFIELD_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerTextFieldPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LOCATION_PICKER_TEXTFIELD_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerClearButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOCATION_PICKER_TEXTFIELD_CLEAR_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerSearchResult:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LOCATION_PICKER_SEARCH_RESULT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerAddress:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LOCATION_PICKER_ADDRESS_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerAddressPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_LOCATION_PICKER_ADDRESS_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLocationPickerSendLocationButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOCATION_PICKER_SEND_LOCATION_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewCancelButton:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_CANCEL_BUTTON_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewItemCount:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_ITEM_COUNT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewCaption:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_CAPTION_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewCaptionPlaceholder:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_CAPTION_PLACEHOLDER_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewCaptionLetterCount:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_CAPTION_LETTER_COUNT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewSendButtonLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_SEND_BUTTON_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewWarningTitle:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_WARNING_TITLE_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontMediaPreviewWarningBody:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_MEDIA_PREVIEW_WARNING_BODY_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontImageDetailSenderName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_IMAGE_DETAIL_SENDER_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontImageDetailMessageStatus:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_IMAGE_DETAIL_MESSAGE_STATUS_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontImageDetailCaption:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_IMAGE_DETAIL_CAPTION_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontCustomNotificationTitleLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_CUSTOM_NOTIFICATION_TITLE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontCustomNotificationContentLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_CUSTOM_NOTIFICATION_CONTENT_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontSelectedMemberListName:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_SELECTED_MEMBER_LIST_NAME_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontGroupMemberCount:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_GROUP_MEMBER_COUNT_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontCountryPickerLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:TAP_COUNTRY_PICKER_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLoginVerificationInfoLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontMedium];
            font = [font fontWithSize:TAP_LOGIN_VERIFICATION_INFO_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLoginVerificationPhoneNumberLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOGIN_VERIFICATION_PHONE_NUMBER_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLoginVerificationStatusCountdownLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOGIN_VERIFICATION_STATUS_COUNTDOWN_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLoginVerificationStatusLoadingLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOGIN_VERIFICATION_STATUS_LOADING_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontLoginVerificationStatusSuccessLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_LOGIN_VERIFICATION_STATUS_SUCCESS_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomAvatarSmallLabel:
        {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_DEFAULT_ROOM_AVATAR_SMALL_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomAvatarMediumLabel:
        {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_DEFAULT_ROOM_AVATAR_MEDIUM_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomAvatarLargeLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_DEFAULT_ROOM_AVATAR_LARGE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        case TAPComponentFontRoomAvatarExtraLargeLabel:
        {
            
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
            font = [font fontWithSize:TAP_DEFAULT_ROOM_AVATAR_EXTRA_LARGE_LABEL_FONTSIZE_STYLE];
            return font;
            break;
        }
        default: {
            UIFont *font = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontRegular];
            font = [font fontWithSize:[UIFont systemFontSize]];
            return font;
            break;
        }
    }
}

- (UIColor *)retrieveColorDataWithIdentifier:(TAPDefaultColor)defaultColorType {
    UIColor *obtainedColor = [self.defaultColorDictionary objectForKey:[NSNumber numberWithInteger:defaultColorType]];
    if (obtainedColor != nil) {
        return obtainedColor;
    }
    
    switch (defaultColorType) {
        case TAPDefaultColorPrimaryExtraLight:
        {
            return [TAPUtil getColor:TAP_COLOR_PRIMARY_EXTRA_LIGHT];
            break;
        }
        case TAPDefaultColorPrimaryLight:
        {
            return [TAPUtil getColor:TAP_COLOR_PRIMARY_LIGHT];
            break;
        }
        case TAPDefaultColorPrimary:
        {
            return [TAPUtil getColor:TAP_COLOR_PRIMARY];
            break;
        }
        case TAPDefaultColorPrimaryDark:
        {
            return [TAPUtil getColor:TAP_COLOR_PRIMARY_DARK];
            break;
        }
        case TAPDefaultColorSuccess:
        {
            return [TAPUtil getColor:TAP_COLOR_SUCCESS];
            break;
        }
        case TAPDefaultColorError:
        {
            return [TAPUtil getColor:TAP_COLOR_ERROR];
            break;
        }
        case TAPDefaultColorTextLight:
        {
            return [TAPUtil getColor:TAP_COLOR_TEXT_LIGHT];
            break;
        }
        case TAPDefaultColorTextMedium:
        {
            return [TAPUtil getColor:TAP_COLOR_TEXT_MEDIUM];
            break;
        }
        case TAPDefaultColorTextDark:
        {
            return [TAPUtil getColor:TAP_COLOR_TEXT_DARK];
            break;
        }
        case TAPDefaultColorIconPrimary:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_PRIMARY];
            break;
        }
        case TAPDefaultColorIconWhite:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_WHITE];
            break;
        }
        case TAPDefaultColorIconGray:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_GRAY];
            break;
        }
        case TAPDefaultColorIconSuccess:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_SUCCESS];
            break;
        }
        case TAPDefaultColorIconDestructive:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_ERROR];
            break;
        }
            
        default:
        {
            //Set default color to black to prevent crash
            return [TAPUtil getColor:TAP_COLOR_TEXT_DARK];
            break;
        }
    }
}

- (UIColor *)retrieveTextColorDataWithIdentifier:(TAPTextColor)textColorType {
    UIColor *obtainedTextColor = [self.textColorDictionary objectForKey:[NSNumber numberWithInteger:textColorType]];
    if (obtainedTextColor != nil) {
        return obtainedTextColor;
    }
    
    switch (textColorType) {
        case TAPTextColorTitleLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorNavigationBarTitleLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorNavigationBarButtonLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorFormLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorFormDescriptionLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorFormErrorInfoLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPTextColorFormTextField: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorFormTextFieldPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorClickableLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorClickableDestructiveLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPTextColorButtonLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorInfoLabelTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorInfoLabelSubtitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorInfoLabelSubtitleBold: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorInfoLabelBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorInfoLabelBodyBold: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorKeyboardAccessoryLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorPopupLoadingLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorSearchConnectionLostTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorSearchConnectionLostDescription: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorUnreadBadgeLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorSearchBarText: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorSearchBarTextPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorSearchBarTextCancelButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorPopupDialogTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorPopupDialogBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorPopupDialogButtonTextPrimary: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorPopupDialogButtonTextSecondary: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorActionSheetDefaultLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorActionSheetDestructiveLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPTextColorActionSheetCancelButtonLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorTableViewSectionHeaderLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorContactListName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorContactListNameHighlighted: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorContactListUsername: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorMediaListInfoLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorRoomListName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRoomListNameHighlighted: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorRoomListMessage: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorRoomListMessageHighlighted: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorRoomListTime: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorGroupRoomListSenderName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRoomListUnreadBadgeLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorNewChatMenuLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorChatProfileRoomNameLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorChatProfileMenuLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorChatProfileMenuDestructiveLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPTextColorSearchNewContactResultName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorSearchNewContactResultUsername: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorAlbumNameLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorAlbumCountLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorGalleryPickerCancelButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorGalleryPickerContinueButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorChatRoomNameLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorChatRoomStatusLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorChatComposerTextField: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorChatComposerTextFieldPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorCustomKeyboardItemLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorQuoteLayoutTitleLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorQuoteLayoutContentLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRightBubbleMessageBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleMessageBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRightBubbleMessageBodyURL: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleMessageBodyURL: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorRightBubbleMessageBodyURLHighlighted: {
            UIColor *color = [TAPUtil getColor:@"5AC8FA"];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleMessageBodyURLHighlighted: {
            UIColor *color = [TAPUtil getColor:@"5AC8FA"];
            return color;
            break;
        }
        case TAPTextColorRightBubbleDeletedMessageBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleDeletedMessageBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorRightBubbleQuoteTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleQuoteTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRightBubbleQuoteContent: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleQuoteContent: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRightFileBubbleName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftFileBubbleName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorRightFileBubbleInfo: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorLeftFileBubbleInfo: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLeftBubbleSenderName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorBubbleMessageStatus: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorBubbleMediaInfo: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorSystemMessageBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorChatRoomUnreadBadge: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorUnreadMessageIdentifier: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorUnreadMessageButtonLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorDeletedChatRoomInfoTitleLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorDeletedChatRoomInfoContentLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorLocationPickerTextField: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLocationPickerTextFieldPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorLocationPickerClearButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorLocationPickerSearchResult: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLocationPickerAddress: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLocationPickerAddressPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorLocationPickerSendLocationButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewCancelButton: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewItemCount: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewCaption: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewCaptionPlaceholder: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewCaptionLetterCount: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewSendButtonLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewWarningTitle: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorMediaPreviewWarningBody: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorImageDetailSenderName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorImageDetailMessageStatus: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorImageDetailCaption: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorCustomNotificationTitleLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorCustomNotificationContentLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorSelectedMemberListName: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPComponentFontGroupMemberCount: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorCountryPickerLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationInfoLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationPhoneNumberLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationStatusCountdownLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationStatusLoadingLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationStatusSuccessLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorSuccess];
            return color;
            break;
        }
        case TAPTextColorLoginVerificationCodeInputLabel: {
            UIColor *color = [TAPUtil getColor:@"191919"];
            return color;
            break;
        }
        case TAPTextColorSearchClearHistoryLabel: {
            UIColor *color = [TAPUtil getColor:@"9B9B9B"];
            return color;
            break;
        }
        case TAPTextColorCreateGroupSubjectLoadingLabel: {
            UIColor *color = [TAPUtil getColor:@"9B9B9B"];
            return color;
            break;
        }
        case TAPTextColorCustomWebViewNavigationTitleLabel: {
            UIColor *color = [TAPUtil getColor:@"191919"];
            return color;
            break;
        }
        case TAPTextColorRoomAvatarSmallLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorRoomAvatarMediumLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorRoomAvatarLargeLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPTextColorRoomAvatarExtraLargeLabel: {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        default: {
            //Set default color to black to prevent crash
            UIColor *color = [TAPUtil getColor:@"9B9B9B"];
            return color;
            break;
        }
    }
}

- (UIColor *)retrieveComponentColorDataWithIdentifier:(TAPComponentColor)componentType {
    UIColor *obtainedComponentColor = [self.componentColorDictionary objectForKey:[NSNumber numberWithInteger:componentType]];
    if (obtainedComponentColor != nil) {
        return obtainedComponentColor;
    }
    
    switch (componentType) {
        case TAPComponentColorDefaultNavigationBarBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_DEFAULT_NAVIGATION_BAR_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorDefaultBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_DEFAULT_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorTextFieldCursor:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorTextFieldBorderActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;

        }
        case TAPComponentColorTextFieldBorderInactive:
        {
            UIColor *color = [TAPUtil getColor:TAP_TEXTFIELD_BORDER_INACTIVE_COLOR];
            return color;
            break;

        }
        case TAPComponentColorTextFieldBorderError:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;

        }
        case TAPComponentColorButtonActiveBackgroundGradientLight:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryLight];
            return color;
            break;

        }
        case TAPComponentColorButtonActiveBackgroundGradientDark:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryDark];
            return color;
            break;
        }
        case TAPComponentColorButtonActiveBorder:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorButtonInactiveBackgroundGradientLight:
        {
            UIColor *color = [TAPUtil getColor:TAP_BUTTON_INACTIVE_BACKGROUND_GRADIENT_LIGHT_COLOR];
            return color;
            break;
        }
        case TAPComponentColorButtonInactiveBackgroundGradientDark:
        {
            UIColor *color = [TAPUtil getColor:TAP_BUTTON_INACTIVE_BACKGROUND_GRADIENT_DARK_COLOR];
            return color;
            break;
        }
        case TAPComponentColorButtonInactiveBorder:
        {
            UIColor *color = [TAPUtil getColor:TAP_BUTTON_INACTIVE_BORDER_COLOR];
            return color;
            break;
        }
        case TAPComponentColorButtonDestructiveBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPComponentColorSwitchActiveBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorSwitchInactiveBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_SWITCH_INACTIVE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorPopupDialogPrimaryButtonSuccessBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorSuccess];
            return color;
            break;
        }
        case TAPComponentColorPopupDialogPrimaryButtonErrorBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPComponentColorPopupDialogSecondaryButtonBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_POPUP_DIALOG_SECONDARY_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorUnreadBadgeBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorUnreadBadgeInactiveBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_UNREAD_BADGE_INACTIVE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorTableViewSectionIndex:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorSearchBarBorderActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorSearchBarBorderInactive:
        {
            UIColor *color = [TAPUtil getColor:TAP_SEARCHBAR_BORDER_INACTIVE_COLOR];
            return color;
            break;
        }
        case TAPComponentColorRoomListUnreadBadgeBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorRoomListUnreadBadgeInactiveBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_UNREAD_BADGE_INACTIVE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorChatRoomBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_DEFAULT_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorChatRoomUnreadBadgeBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorChatRoomUnreadBadgeInactiveBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_UNREAD_BADGE_INACTIVE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorQuoteLayoutDecorationBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryExtraLight];
            return color;
            break;
        }
        case TAPComponentColorLeftBubbleBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_LEFT_BUBBLE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorRightBubbleBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorLeftBubbleQuoteBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_LEFT_BUBBLE_QUOTE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorRightBubbleQuoteBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryDark];
            return color;
            break;
        }
        case TAPComponentColorLeftFileButtonBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorRightFileButtonBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryDark];
            return color;
            break;
        }
        case TAPComponentColorSystemMessageBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_SYSTEM_MESSAGE_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorSystemMessageBackgroundShadow:
        {
            UIColor *color = [TAPUtil getColor:TAP_SYSTEM_MESSAGE_BACKGROUND_SHADOW_COLOR];
            return color;
            break;
        }
        case TAPComponentColorFileProgressBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_FILE_PROGRESS_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorDeletedChatRoomInfoBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_DELETED_CHAT_ROOM_INFO_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorChatComposerBackground:
        {
            UIColor *color = [TAPUtil getColor:TAP_CHAT_COMPOSER_BACKGROUND_COLOR];
            return color;
            break;
        }
        case TAPComponentColorUnreadIdentifierBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorSelectedMediaPreviewThumbnailBorder:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorMediaPreviewWarningBackgroundColor:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorError];
            return color;
            break;
        }
        case TAPComponentColorSearchConnectionLostBackgroundColor:
        {
            UIColor *color = [TAPUtil getColor:TAP_SEARCH_CONNECTION_LOST_BACKGROUND_COLOR];
            return color;
            break;
        }
//ICON
//General
        case TAPComponentColorButtonIcon:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextLight];
            return color;
            break;
        }
        case TAPComponentColorButtonIconPrimary:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
            return color;
            break;
        }
        case TAPComponentColorButtonIconDestructive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
        case TAPComponentColorIconMessageSending:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconMessageFailed:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconMessageSent:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconMessageDelivered:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconMessageRead:
        {
            UIColor *color = [TAPUtil getColor:@"19C700"];
            return color;
            break;
        }
        case TAPComponentColorIconMessageDeleted:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconRemoveItem:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconRemoveItemBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
        case TAPComponentColorIconLoadingProgressPrimary:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconLoadingProgressWhite:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChevronRightPrimary:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChevronRightGray:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChecklist:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconLoadingPopupSuccess:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconSearchConnectionLost:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPComponentColorIconCircleSelectionActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconCircleSelectionInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
//Navigation Bar
        case TAPComponentColorIconNavigationBarBackButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconTransparentBackgroundBackButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconNavigationBarCloseButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconClearTextButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconSearchBarMagnifier:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
//Action Sheet
        case TAPComponentColorIconActionSheetDocument:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetCamera:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetGallery:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetLocation:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetComposeEmail:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetCopy:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetOpen:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetSMS:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetCall:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetReply:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetForward:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconActionSheetTrash:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
//Register
        case TAPComponentColorIconViewPasswordActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconViewPasswordInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChangePicture:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconSelectPictureCamera:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconSelectPictureGallery:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
//Chat Room
        case TAPComponentColorIconChatRoomCancelQuote:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconCancelUploadDownload:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerSend:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerSendInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerBurgerMenu:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerShowKeyboard:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerSendBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerSendBackgroundInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconDeletedLeftMessageBubble:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconDeletedRightMessageBubble:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconUserStatusActive:
        {
            UIColor *color = [TAPUtil getColor:@"19C700"];
            return color;
            break;
        }
        case TAPComponentColorIconLocationBubbleMarker:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconQuotedFileBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconDeletedChatRoom:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatRoomScrollToBottomBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconChatRoomScrollToBottom:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatRoomUnreadButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatRoomFloatingUnreadButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerBurgerMenuBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerShowKeyboardBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatComposerAttach:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconFile:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconFileUploadDownload:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconFileCancelUploadDownload:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconFileRetryUploadDownload:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconFilePlayMedia:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
    //Room List
        case TAPComponentColorIconStartNewChatButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconRoomListMuted:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
    //Room List Setup
        case TAPComponentColorIconRoomListSettingUp:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconRoomListSetUpSuccess:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconSuccess];
            return color;
            break;
        }
        case TAPComponentColorIconRoomListSetUpFailure:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
        case TAPComponentColorIconRoomListRetrySetUpButton:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
    //New Chat page
        case TAPComponentColorIconMenuNewContact:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconMenuScanQRCode:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconMenuNewGroup:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
    //Chat / Group Profile
        case TAPComponentColorIconChatProfileMenuNotificationActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconChatProfileMenuNotificationInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChatProfileMenuConversationColor:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChatProfileMenuBlockUser:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChatProfileMenuSearchChat:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconChatProfileMenuClearChat:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
        case TAPComponentColorIconGroupProfileMenuViewMembers:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconGroupMemberProfileMenuAddToContacts:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconGroupMemberProfileMenuSendMessage:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconGroupMemberProfileMenuPromoteAdmin:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconGroupMemberProfileMenuDemoteAdmin:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconGray];
            return color;
            break;
        }
        case TAPComponentColorIconGroupMemberProfileMenuRemoveMember:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
    //Media / Image Detail Preview
        case TAPComponentColorIconMediaPreviewAdd:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconMediaPreviewWarning:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconMediaPreviewThumbnailWarning:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconMediaPreviewThumbnailWarningBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconDestructive];
            return color;
            break;
        }
        case TAPComponentColorIconSaveImage:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconMediaListVideo:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
    //Scan Result
        case TAPComponentColorIconCloseScanResult:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconCloseScanResultBackground:
        {
            UIColor *color = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.5f];
            return color;
            break;
        }
    //Location Picker
        case TAPComponentColorIconLocationPickerMarker:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerRecenter:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerRecenterBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerSendLocation:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconWhite];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerSendLocationBackground:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorIconPrimary];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerAddressActive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextDark];
            return color;
            break;
        }
        case TAPComponentColorIconLocationPickerAddressInactive:
        {
            UIColor *color = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorTextMedium];
            return color;
            break;
        }
        default: {
            //Set default color to black to prevent crash
            UIColor *color = [TAPUtil getColor:@"9B9B9B"];
            return color;
            break;
        }
    }
}

- (UIColor *)getRandomDefaultAvatarBackgroundColorWithName:(NSString *)name {
    if (name == nil || [name isEqualToString:@""]) {
        UIColor *color = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_1];
        return color;
    }
    
    char *charString = [name UTF8String];
    NSInteger lastIndex = [name length] - 1;
    NSInteger firstCharInt = charString[0] - '0';
    NSInteger lastCharInt = charString[lastIndex] - '0';
    
    //DV Note - 8 is total number of random colors, needs to change it if added or deleted
    NSInteger obtainedIndex = (firstCharInt + lastCharInt) % 8;
    
    UIColor *resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_1];
    switch (obtainedIndex) {
        case 0:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_1];
            break;
        }
        case 1:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_2];
            break;
        }
        case 2:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_3];
            break;
        }
        case 3:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_4];
            break;
        }
        case 4:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_5];
            break;
        }
        case 5:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_6];
            break;
        }
        case 6:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_7];
            break;
        }
        case 7:
        {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_8];
            break;
        }
        default: {
            resultColor = [TAPUtil getColor:TAP_AVATAR_BACKGROUND_COLOR_1];
            break;
        }
    }
    
    return resultColor;
}

- (NSString *)getInitialsWithName:(NSString *)name isGroup:(BOOL)isGroup {
    NSMutableString *displayString = [NSMutableString stringWithString:@""];
    NSMutableArray *words = [[name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    if ([words count]) {
        NSString *firstWord = [words firstObject];
        if ([firstWord length]) {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            NSRange firstLetterRange = [firstWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
            [displayString appendString:[firstWord substringWithRange:firstLetterRange]];
        }
        
        if (isGroup) {
            return displayString;
        }
        
        if ([words count] >= 2) {
            NSString *lastWord = [words lastObject];
            
            while ([lastWord length] == 0 && [words count] >= 2) {
                [words removeLastObject];
                lastWord = [words lastObject];
            }
            
            if ([words count] > 1) {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                NSRange lastLetterRange = [lastWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
                [displayString appendString:[lastWord substringWithRange:lastLetterRange]];
            }
        }
        
        return displayString;
    }
    
    return displayString;
}

@end
