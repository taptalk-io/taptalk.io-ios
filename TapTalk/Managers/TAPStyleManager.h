//
//  TAPStyleManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/06/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPDefaultColor) {
    TAPDefaultColorPrimaryExtraLight,
    TAPDefaultColorPrimaryLight,
    TAPDefaultColorPrimary,
    TAPDefaultColorPrimaryDark,
    TAPDefaultColorSuccess,
    TAPDefaultColorError,
    TAPDefaultColorTextLight,
    TAPDefaultColorTextMedium,
    TAPDefaultColorTextDark,
    TAPDefaultColorIconPrimary,
    TAPDefaultColorIconWhite,
    TAPDefaultColorIconGray,
    TAPDefaultColorIconSuccess,
    TAPDefaultColorIconDestructive,
    
};

typedef NS_ENUM(NSInteger, TAPDefaultFont) {
    TAPDefaultFontRegular,
    TAPDefaultFontMedium,
    TAPDefaultFontBold,
    TAPDefaultFontItalic
};

typedef NS_ENUM(NSInteger, TAPComponentColor) {
    TAPComponentColorDefaultNavigationBarBackground,
    TAPComponentColorDefaultBackground,
    TAPComponentColorTextFieldCursor,
    TAPComponentColorTextFieldBorderActive,
    TAPComponentColorTextFieldBorderInactive,
    TAPComponentColorTextFieldBorderError,
    TAPComponentColorButtonActiveBackgroundGradientLight,
    TAPComponentColorButtonActiveBackgroundGradientDark,
    TAPComponentColorButtonActiveBorder,
    TAPComponentColorButtonInactiveBackgroundGradientLight,
    TAPComponentColorButtonInactiveBackgroundGradientDark,
    TAPComponentColorButtonInactiveBorder,
    TAPComponentColorSwitchActiveBackground,
    TAPComponentColorSwitchInactiveBackground,
    TAPComponentColorPopupDialogPrimaryButtonSuccessBackground,
    TAPComponentColorPopupDialogPrimaryButtonErrorBackground,
    TAPComponentColorPopupDialogSecondaryButtonBackground,
    TAPComponentColorUnreadBadgeBackground,
    TAPComponentColorUnreadBadgeInactiveBackground,
    TAPComponentColorTableViewSectionIndex,
    TAPComponentColorSearchBarBorderActive,
    TAPComponentColorSearchBarBorderInactive,
    TAPComponentColorRoomListUnreadBadgeBackground,
    TAPComponentColorRoomListUnreadBadgeInactiveBackground,
    TAPComponentColorChatRoomUnreadBadgeBackground,
    TAPComponentColorChatRoomUnreadBadgeInactiveBackground,
    TAPComponentColorQuoteLayoutDecorationBackground,
    TAPComponentColorLeftBubbleBackground,
    TAPComponentColorRightBubbleBackground,
    TAPComponentColorLeftBubbleQuoteBackground,
    TAPComponentColorRightBubbleQuoteBackground,
    TAPComponentColorLeftFileButtonBackground,
    TAPComponentColorRightFileButtonBackground,
    TAPComponentColorSystemMessageBackground,
    TAPComponentColorSystemMessageBackgroundShadow,
    TAPComponentColorFileProgressBackground,
    TAPComponentColorDeletedChatRoomInfoBackground,
    TAPComponentColorChatComposerBackground,
    TAPComponentColorUnreadIdentifierBackground,
    TAPComponentColorSelectedMediaPreviewThumbnailBorder,
    TAPComponentColorMediaPreviewWarningBackgroundColor,
    TAPComponentColorSearchConnectionLostBackgroundColor,
    TAPComponentColorButtonIcon,
    TAPComponentColorButtonIconDestructive,
    TAPComponentColorIconMessageSending,
    TAPComponentColorIconMessageFailed,
    TAPComponentColorIconMessageSent,
    TAPComponentColorIconMessageDelivered,
    TAPComponentColorIconMessageRead,
    TAPComponentColorIconMessageDeleted,
    TAPComponentColorIconNavigationBarBackButton, //Navigation Bar
    TAPComponentColorIconTransparentBackgroundBackButton, //Navigation Bar
    TAPComponentColorIconNavigationBarCloseButton, //Navigation Bar
    TAPComponentColorIconClearTextButton, //Navigation Bar
    TAPComponentColorIconActionSheetDocument, //Action Sheet
    TAPComponentColorIconActionSheetCamera, //Action Sheet
    TAPComponentColorIconActionSheetGallery, //Action Sheet
    TAPComponentColorIconActionSheetLocation, //Action Sheet
    TAPComponentColorIconActionSheetComposeEmail, //Action Sheet
    TAPComponentColorIconActionSheetCopy, //Action Sheet
    TAPComponentColorIconActionSheetOpen, //Action Sheet
    TAPComponentColorIconActionSheetSMS, //Action Sheet
    TAPComponentColorIconActionSheetCall, //Action Sheet
    TAPComponentColorIconActionSheetReply, //Action Sheet
    TAPComponentColorIconActionSheetForward, //Action Sheet
    TAPComponentColorIconActionSheetTrash, //Action Sheet
    TAPComponentColorIconChatRoomCancelQuote, //Chat Room
    TAPComponentColorIconCancelUploadDownload, //Chat Room
    TAPComponentColorIconChatComposerSend, //Chat Room
    TAPComponentColorIconChatComposerSendInactive, //Chat Room
    TAPComponentColorIconChatComposerBurgerMenu, //Chat Room
    TAPComponentColorIconChatComposerShowKeyboard, //Chat Room
    TAPComponentColorIconChatComposerSendBackground, //Chat Room
    TAPComponentColorIconChatComposerSendBackgroundInactive, //Chat Room
    
};

typedef NS_ENUM(NSInteger, TAPTextColor) {
    TAPTextColorTitleLabel,
    TAPTextColorNavigationBarTitleLabel,
    TAPTextColorNavigationBarButtonLabel,
    TAPTextColorFormLabel,
    TAPTextColorFormDescriptionLabel,
    TAPTextColorFormErrorInfoLabel,
    TAPTextColorFormTextField,
    TAPTextColorFormTextFieldPlaceholder,
    TAPTextColorClickableLabel,
    TAPTextColorClickableDestructiveLabel,
    TAPTextColorButtonLabel,
    TAPTextColorInfoLabelTitle,
    TAPTextColorInfoLabelSubtitle,
    TAPTextColorInfoLabelSubtitleBold,
    TAPTextColorInfoLabelBody,
    TAPTextColorInfoLabelBodyBold,
    TAPTextColorKeyboardAccessoryLabel,
    TAPTextColorPopupLoadingLabel,
    TAPTextColorSearchConnectionLostTitle,
    TAPTextColorSearchConnectionLostDescription,
    TAPTextColorUnreadBadgeLabel,
    TAPTextColorSearchBarText,
    TAPTextColorSearchBarTextPlaceholder,
    TAPTextColorSearchBarTextCancelButton,
    TAPTextColorPopupDialogTitle,
    TAPTextColorPopupDialogBody,
    TAPTextColorPopupDialogButtonTextPrimary,
    TAPTextColorPopupDialogButtonTextSecondary,
    TAPTextColorActionSheetDefaultLabel,
    TAPTextColorActionSheetDestructiveLabel,
    TAPTextColorActionSheetCancelButtonLabel,
    TAPTextColorTableViewSectionHeaderLabel,
    TAPTextColorContactListName,
    TAPTextColorContactListNameHighlighted,
    TAPTextColorMediaListInfoLabel,
    TAPTextColorRoomListName,
    TAPTextColorRoomListNameHighlighted,
    TAPTextColorRoomListMessage,
    TAPTextColorRoomListMessageHighlighted,
    TAPTextColorRoomListTime,
    TAPTextColorGroupRoomListSenderName,
    TAPTextColorRoomListUnreadBadgeLabel,
    TAPTextColorNewChatMenuLabel,
    TAPTextColorChatProfileRoomNameLabel,
    TAPTextColorChatProfileMenuLabel,
    TAPTextColorChatProfileMenuDestructiveLabel,
    TAPTextColorSearchNewContactResultName,
    TAPTextColorSearchNewContactResultUsername,
    TAPTextColorAlbumNameLabel,
    TAPTextColorAlbumCountLabel,
    TAPTextColorGalleryPickerCancelButton,
    TAPTextColorGalleryPickerContinueButton,
    TAPTextColorChatRoomNameLabel,
    TAPTextColorChatRoomStatusLabel,
    TAPTextColorChatComposerTextField,
    TAPTextColorChatComposerTextFieldPlaceholder,
    TAPTextColorCustomKeyboardItemLabel,
    TAPTextColorQuoteLayoutTitleLabel,
    TAPTextColorQuoteLayoutContentLabel,
    TAPTextColorRightBubbleMessageBody,
    TAPTextColorLeftBubbleMessageBody,
    TAPTextColorRightBubbleMessageBodyURL,
    TAPTextColorLeftBubbleMessageBodyURL,
    TAPTextColorRightBubbleMessageBodyURLHighlighted,
    TAPTextColorLeftBubbleMessageBodyURLHighlighted,
    TAPTextColorRightBubbleDeletedMessageBody,
    TAPTextColorLeftBubbleDeletedMessageBody,
    TAPTextColorRightBubbleQuoteTitle,
    TAPTextColorLeftBubbleQuoteTitle,
    TAPTextColorRightBubbleQuoteContent,
    TAPTextColorLeftBubbleQuoteContent,
    TAPTextColorRightFileBubbleName,
    TAPTextColorLeftFileBubbleName,
    TAPTextColorRightFileBubbleInfo,
    TAPTextColorLeftFileBubbleInfo,
    TAPTextColorLeftBubbleSenderName,
    TAPTextColorBubbleMessageStatus,
    TAPTextColorBubbleMediaInfo,
    TAPTextColorSystemMessageBody,
    TAPTextColorChatRoomUnreadBadge,
    TAPTextColorUnreadMessageIdentifier,
    TAPTextColorUnreadMessageButtonLabel,
    TAPTextColorDeletedChatRoomInfoTitleLabel,
    TAPTextColorDeletedChatRoomInfoContentLabel,
    TAPTextColorLocationPickerTextField,
    TAPTextColorLocationPickerTextFieldPlaceholder,
    TAPTextColorLocationPickerClearButton,
    TAPTextColorLocationPickerSearchResult,
    TAPTextColorLocationPickerAddress,
    TAPTextColorLocationPickerAddressPlaceholder,
    TAPTextColorLocationPickerSendLocationButton,
    TAPTextColorMediaPreviewCancelButton,
    TAPTextColorMediaPreviewItemCount,
    TAPTextColorMediaPreviewCaption,
    TAPTextColorMediaPreviewCaptionPlaceholder,
    TAPTextColorMediaPreviewCaptionLetterCount,
    TAPTextColorMediaPreviewSendButtonLabel,
    TAPTextColorMediaPreviewWarningTitle,
    TAPTextColorMediaPreviewWarningBody,
    TAPTextColorImageDetailSenderName,
    TAPTextColorImageDetailMessageStatus,
    TAPTextColorImageDetailCaption,
    TAPTextColorCustomNotificationTitleLabel,
    TAPTextColorCustomNotificationContentLabel,
    TAPTextColorSelectedMemberListName,
    TAPTextColorGroupMemberCount,
    TAPTextColorCountryPickerLabel,
    TAPTextColorLoginVerificationInfoLabel,
    TAPTextColorLoginVerificationPhoneNumberLabel,
    TAPTextColorLoginVerificationStatusCountdownLabel,
    TAPTextColorLoginVerificationStatusLoadingLabel,
    TAPTextColorLoginVerificationStatusSuccessLabel,
    TAPTextColorLoginVerificationCodeInputLabel,
    TAPTextColorSearchClearHistoryLabel,
    TAPTextColorCreateGroupSubjectLoadingLabel,
    TAPTextColorCustomWebViewNavigationTitleLabel
};

typedef NS_ENUM(NSInteger, TAPComponentFont) {
    TAPComponentFontTitleLabel,
    TAPComponentFontNavigationBarTitleLabel,
    TAPComponentFontNavigationBarButtonLabel,
    TAPComponentFontFormLabel,
    TAPComponentFontFormDescriptionLabel,
    TAPComponentFontFormErrorInfoLabel,
    TAPComponentFontFormTextField,
    TAPComponentFontFormTextFieldPlaceholder,
    TAPComponentFontClickableLabel,
    TAPComponentFontClickableDestructiveLabel,
    TAPComponentFontButtonLabel,
    TAPComponentFontInfoLabelTitle,
    TAPComponentFontInfoLabelSubtitle,
    TAPComponentFontInfoLabelSubtitleBold,
    TAPComponentFontInfoLabelBody,
    TAPComponentFontInfoLabelBodyBold,
    TAPComponentFontKeyboardAccessoryLabel,
    TAPComponentFontPopupLoadingLabel,
    TAPComponentFontSearchConnectionLostTitle,
    TAPComponentFontSearchConnectionLostDescription,
    TAPComponentFontUnreadBadgeLabel,
    TAPComponentFontSearchBarText,
    TAPComponentFontSearchBarTextPlaceholder,
    TAPComponentFontSearchBarTextCancelButton,
    TAPComponentFontPopupDialogTitle,
    TAPComponentFontPopupDialogBody,
    TAPComponentFontPopupDialogButtonTextPrimary,
    TAPComponentFontPopupDialogButtonTextSecondary,
    TAPComponentFontActionSheetDefaultLabel,
    TAPComponentFontActionSheetDestructiveLabel,
    TAPComponentFontActionSheetCancelButtonLabel,
    TAPComponentFontTableViewSectionHeaderLabel,
    TAPComponentFontContactListName,
    TAPComponentFontContactListNameHighlighted,
    TAPComponentFontMediaListInfoLabel,
    TAPComponentFontRoomListName,
    TAPComponentFontRoomListNameHighlighted,
    TAPComponentFontRoomListMessage,
    TAPComponentFontRoomListMessageHighlighted,
    TAPComponentFontRoomListTime,
    TAPComponentFontGroupRoomListSenderName,
    TAPComponentFontRoomListUnreadBadgeLabel,
    TAPComponentFontNewChatMenuLabel,
    TAPComponentFontChatProfileRoomNameLabel,
    TAPComponentFontChatProfileMenuLabel,
    TAPComponentFontChatProfileMenuDestructiveLabel,
    TAPComponentFontSearchNewContactResultName,
    TAPComponentFontSearchNewContactResultUsername,
    TAPComponentFontAlbumNameLabel,
    TAPComponentFontAlbumCountLabel,
    TAPComponentFontGalleryPickerCancelButton,
    TAPComponentFontGalleryPickerContinueButton,
    TAPComponentFontChatRoomNameLabel,
    TAPComponentFontChatRoomStatusLabel,
    TAPComponentFontChatComposerTextField,
    TAPComponentFontChatComposerTextFieldPlaceholder,
    TAPComponentFontCustomKeyboardItemLabel,
    TAPComponentFontQuoteLayoutTitleLabel,
    TAPComponentFontQuoteLayoutContentLabel,
    TAPComponentFontRightBubbleMessageBody,
    TAPComponentFontLeftBubbleMessageBody,
    TAPComponentFontRightBubbleMessageBodyURL,
    TAPComponentFontLeftBubbleMessageBodyURL,
    TAPComponentFontRightBubbleMessageBodyURLHighlighted,
    TAPComponentFontLeftBubbleMessageBodyURLHighlighted,
    TAPComponentFontRightBubbleDeletedMessageBody,
    TAPComponentFontLeftBubbleDeletedMessageBody,
    TAPComponentFontRightBubbleQuoteTitle,
    TAPComponentFontLeftBubbleQuoteTitle,
    TAPComponentFontRightBubbleQuoteContent,
    TAPComponentFontLeftBubbleQuoteContent,
    TAPComponentFontRightFileBubbleName,
    TAPComponentFontLeftFileBubbleName,
    TAPComponentFontRightFileBubbleInfo,
    TAPComponentFontLeftFileBubbleInfo,
    TAPComponentFontLeftBubbleSenderName,
    TAPComponentFontBubbleMessageStatus,
    TAPComponentFontBubbleMediaInfo,
    TAPComponentFontSystemMessageBody,
    TAPComponentFontChatRoomUnreadBadge,
    TAPComponentFontUnreadMessageIdentifier,
    TAPComponentFontUnreadMessageButtonLabel,
    TAPComponentFontDeletedChatRoomInfoTitleLabel,
    TAPComponentFontDeletedChatRoomInfoContentLabel,
    TAPComponentFontLocationPickerTextField,
    TAPComponentFontLocationPickerTextFieldPlaceholder,
    TAPComponentFontLocationPickerClearButton,
    TAPComponentFontLocationPickerSearchResult,
    TAPComponentFontLocationPickerAddress,
    TAPComponentFontLocationPickerAddressPlaceholder,
    TAPComponentFontLocationPickerSendLocationButton,
    TAPComponentFontMediaPreviewCancelButton,
    TAPComponentFontMediaPreviewItemCount,
    TAPComponentFontMediaPreviewCaption,
    TAPComponentFontMediaPreviewCaptionPlaceholder,
    TAPComponentFontMediaPreviewCaptionLetterCount,
    TAPComponentFontMediaPreviewSendButtonLabel,
    TAPComponentFontMediaPreviewWarningTitle,
    TAPComponentFontMediaPreviewWarningBody,
    TAPComponentFontImageDetailSenderName,
    TAPComponentFontImageDetailMessageStatus,
    TAPComponentFontImageDetailCaption,
    TAPComponentFontCustomNotificationTitleLabel,
    TAPComponentFontCustomNotificationContentLabel,
    TAPComponentFontSelectedMemberListName,
    TAPComponentFontGroupMemberCount,
    TAPComponentFontCountryPickerLabel,
    TAPComponentFontLoginVerificationInfoLabel,
    TAPComponentFontLoginVerificationPhoneNumberLabel,
    TAPComponentFontLoginVerificationStatusCountdownLabel,
    TAPComponentFontLoginVerificationStatusLoadingLabel,
    TAPComponentFontLoginVerificationStatusSuccessLabel,
};

@interface TAPStyleManager : NSObject

+ (TAPStyleManager *)sharedManager;
- (void)clearStyleManagerData;

- (void)setDefaultFont:(UIFont *)font forType:(TAPDefaultFont)defaultFontType;
- (void)setComponentFont:(UIFont *)font forType:(TAPComponentFont)componentFontType;
- (void)setDefaultColor:(UIColor *)color forType:(TAPDefaultColor)defaultColorType;
- (void)setTextColor:(UIColor *)color forType:(TAPTextColor)textColorType;
- (void)setComponentColor:(UIColor *)color forType:(TAPComponentColor)componentColorType;

- (UIFont *)getDefaultFontForType:(TAPDefaultFont)defaultFontType;
- (UIFont *)getComponentFontForType:(TAPComponentFont)componentFontType;
- (UIColor *)getDefaultColorForType:(TAPDefaultColor)defaultColorType;
- (UIColor *)getTextColorForType:(TAPTextColor)textColorType;
- (UIColor *)getComponentColorForType:(TAPComponentColor)componentType;

@end

NS_ASSUME_NONNULL_END
