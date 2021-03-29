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
    TAPComponentColorDefaultRightBubbleBackground,
    TAPComponentColorDefaultRightBubbleDarkBackground,
    TAPComponentColorDefaultLeftBubbleBackground,
    TAPComponentColorDefaultLeftBubbleDarkBackground,
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
    TAPComponentColorButtonDestructiveBackground,
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
    TAPComponentColorChatRoomBackground,
    TAPComponentColorRoomListBackground,
    TAPComponentColorQuoteLayoutDecorationBackground,
    TAPComponentColorRightBubbleQuoteDecorationBackground,
    TAPComponentColorLeftBubbleQuoteDecorationBackground,
    TAPComponentColorLeftBubbleBackground,
    TAPComponentColorRightBubbleBackground,
    TAPComponentColorLeftBubbleQuoteBackground,
    TAPComponentColorRightBubbleQuoteBackground,
    TAPComponentColorLeftFileButtonBackground,
    TAPComponentColorRightFileButtonBackground,
    TAPComponentColorSystemMessageBackground,
    TAPComponentColorSystemMessageBackgroundShadow,
    TAPComponentColorFileProgressBackgroundPrimary,
    TAPComponentColorFileProgressBackgroundWhite,
    TAPComponentColorDeletedChatRoomInfoBackground,
    TAPComponentColorChatComposerBackground,
    TAPComponentColorUnreadIdentifierBackground,
    TAPComponentColorSelectedMediaPreviewThumbnailBorder,
    TAPComponentColorMediaPreviewWarningBackgroundColor,
    TAPComponentColorSearchConnectionLostBackgroundColor,
    TAPComponentColorButtonIcon,
    TAPComponentColorButtonIconPrimary,
    TAPComponentColorButtonIconDestructive,
    TAPComponentColorIconRoomListMessageSending,
    TAPComponentColorIconRoomListMessageFailed,
    TAPComponentColorIconRoomListMessageSent,
    TAPComponentColorIconRoomListMessageDelivered,
    TAPComponentColorIconRoomListMessageRead,
    TAPComponentColorIconRoomListMessageDeleted,
    TAPComponentColorIconChatRoomMessageSending,
    TAPComponentColorIconChatRoomMessageFailed,
    TAPComponentColorIconChatRoomMessageSent,
    TAPComponentColorIconChatRoomMessageSentImage,
    TAPComponentColorIconChatRoomMessageDelivered,
    TAPComponentColorIconChatRoomMessageDeliveredImage,
    TAPComponentColorIconChatRoomMessageRead,
    TAPComponentColorIconChatRoomMessageDeletedLeft,
    TAPComponentColorIconChatRoomMessageDeletedRight,
    TAPComponentColorIconRemoveItem,
    TAPComponentColorIconRemoveItemBackground,
    TAPComponentColorIconLoadingProgressPrimary,
    TAPComponentColorIconLoadingProgressWhite,
    TAPComponentColorIconChevronRightPrimary,
    TAPComponentColorIconChevronRightGray,
    TAPComponentColorIconChecklist,
    TAPComponentColorIconLoadingPopupSuccess,
    TAPComponentColorIconSearchConnectionLost,
    TAPComponentColorIconCircleSelectionActive,
    TAPComponentColorIconCircleSelectionInactive,
    TAPComponentColorIconNavigationBarBackButton, //Navigation Bar
    TAPComponentColorIconTransparentBackgroundBackButton, //Navigation Bar
    TAPComponentColorIconNavigationBarCloseButton, //Navigation Bar
    TAPComponentColorIconClearTextButton, //Navigation Bar
    TAPComponentColorIconSearchBarMagnifier, //Navigation Bar
    TAPComponentColorIconSearchBarMagnifierActive, //Navigation Bar
    TAPComponentColorIconActionSheetDocument, //Action Sheet
    TAPComponentColorIconActionSheetCamera, //Action Sheet
    TAPComponentColorIconActionSheetGallery, //Action Sheet
    TAPComponentColorIconActionSheetLocation, //Action Sheet
    TAPComponentColorIconActionSheetComposeEmail, //Action Sheet
    TAPComponentColorIconActionSheetCopy, //Action Sheet
    TAPComponentColorIconActionSheetOpen, //Action Sheet
    TAPComponentColorIconActionSheetSMS, //Action Sheet
    TAPComponentColorIconActionSheetSendMessage, //Action Sheet
    TAPComponentColorIconActionSheetViewProfile, //Action Sheet
    TAPComponentColorIconActionSheetCall, //Action Sheet
    TAPComponentColorIconActionSheetReply, //Action Sheet
    TAPComponentColorIconActionSheetForward, //Action Sheet
    TAPComponentColorIconActionSheetTrash, //Action Sheet
    TAPComponentColorIconViewPasswordActive, // Register
    TAPComponentColorIconViewPasswordInactive, // Register
    TAPComponentColorIconChangePicture, // Register
    TAPComponentColorIconSelectPictureCamera, // Register
    TAPComponentColorIconSelectPictureGallery, // Register
    TAPComponentColorIconChatRoomCancelQuote, //Chat Room
    TAPComponentColorIconCancelUploadDownloadPrimary, //Chat Room
    TAPComponentColorIconCancelUploadDownloadWhite, //Chat Room
    TAPComponentColorIconChatComposerSend, //Chat Room
    TAPComponentColorIconChatComposerSendInactive, //Chat Room
    TAPComponentColorIconChatComposerBurgerMenu, //Chat Room
    TAPComponentColorIconChatComposerShowKeyboard, //Chat Room
    TAPComponentColorIconChatComposerSendBackground, //Chat Room
    TAPComponentColorIconChatComposerSendBackgroundInactive, //Chat Room
    TAPComponentColorIconDeletedLeftMessageBubble, //Chat Room
    TAPComponentColorIconDeletedRightMessageBubble, //Chat Room
    TAPComponentColorIconRoomListMuted, //Room List
    TAPComponentColorIconStartNewChatButton, //RoomList
    TAPComponentColorIconRoomListSettingUp, //Room List Setup
    TAPComponentColorIconRoomListSetUpSuccess, //Room List Setup
    TAPComponentColorIconRoomListSetUpFailure, //Room List Setup
    TAPComponentColorIconRoomListRetrySetUpButton, //Room List Setup
    TAPComponentColorIconMenuNewContact, //New Chat Page
    TAPComponentColorIconMenuScanQRCode, //New Chat Page
    TAPComponentColorIconMenuNewGroup, //New Chat Page
    TAPComponentColorIconChatProfileMenuNotificationActive, //Chat / Group Profile Page
    TAPComponentColorIconChatProfileMenuNotificationInactive, //Chat / Group Profile Page
    TAPComponentColorIconChatProfileMenuConversationColor, //Chat / Group Profile Page
    TAPComponentColorIconChatProfileMenuBlockUser, //Chat / Group Profile Page
    TAPComponentColorIconChatProfileMenuSearchChat, //Chat / Group Profile Page
    TAPComponentColorIconChatProfileMenuClearChat, //Chat / Group Profile Page
    TAPComponentColorIconGroupProfileMenuViewMembers, //Chat / Group Profile Page
    TAPComponentColorIconGroupMemberProfileMenuAddToContacts, //Chat / Group Profile Page
    TAPComponentColorIconGroupMemberProfileMenuSendMessage, //Chat / Group Profile Page
    TAPComponentColorIconGroupMemberProfileMenuPromoteAdmin, //Chat / Group Profile Page
    TAPComponentColorIconGroupMemberProfileMenuDemoteAdmin, //Chat / Group Profile Page
    TAPComponentColorIconGroupMemberProfileMenuRemoveMember, //Chat / Group Profile Page
    TAPComponentColorIconMediaPreviewAdd, //Media / Image Detail Preview
    TAPComponentColorIconMediaPreviewWarning, //Media / Image Detail Preview
    TAPComponentColorIconMediaPreviewThumbnailWarning,//Media / Image Detail Preview
    TAPComponentColorIconMediaPreviewThumbnailWarningBackground,//Media / Image Detail Preview
    TAPComponentColorIconSaveImage,//Media / Image Detail Preview
    TAPComponentColorIconMediaListVideo,//Media / Image Detail Preview
    TAPComponentColorIconCloseScanResult, //Scan Result
    TAPComponentColorIconCloseScanResultBackground,//Scan Result
    TAPComponentColorIconLocationPickerMarker, //Location Picker
    TAPComponentColorIconLocationPickerRecenter, //Location Picker
    TAPComponentColorIconLocationPickerRecenterBackground, //Location Picker
    TAPComponentColorIconLocationPickerSendLocation, //Location Picker
    TAPComponentColorIconLocationPickerSendLocationBackground, //Location Picker
    TAPComponentColorIconLocationPickerAddressActive, //Location Picker
    TAPComponentColorIconLocationPickerAddressInactive,//Location Picker
    TAPComponentColorIconUserStatusActive, //Chat Room Page
    TAPComponentColorIconLocationBubbleMarker, //Chat Room Page
    TAPComponentColorIconQuotedFileBackground, //Chat Room Page
    TAPComponentColorIconDeletedChatRoom, //Chat Room Page
    TAPComponentColorIconChatRoomScrollToBottomBackground, //Chat Room Page
    TAPComponentColorIconChatRoomScrollToBottom, //Chat Room Page
    TAPComponentColorIconChatRoomUnreadButton, //Chat Room Page
    TAPComponentColorIconChatRoomFloatingUnreadButton, //Chat Room Page
    TAPComponentColorIconChatComposerBurgerMenuBackground, //Chat Room Page
    TAPComponentColorIconChatComposerShowKeyboardBackground, //Chat Room Page
    TAPComponentColorIconChatComposerAttach, //Chat Room Page
    TAPComponentColorIconFilePrimary, //Chat Room Page
    TAPComponentColorIconFileWhite, //Chat Room Page
    TAPComponentColorIconQuotedFileBackgroundRight, //Chat Room Page
    TAPComponentColorIconQuotedFileBackgroundLeft, //Chat Room Page
    TAPComponentColorIconFileUploadDownloadPrimary, //Chat Room Page
    TAPComponentColorIconFileUploadDownloadWhite, //Chat Room Page
    TAPComponentColorIconFileCancelUploadDownloadPrimary, //Chat Room Page
    TAPComponentColorIconFileCancelUploadDownloadWhite, //Chat Room Page
    TAPComponentColorIconFileRetryUploadDownloadPrimary, //Chat Room Page
    TAPComponentColorIconFileRetryUploadDownloadWhite, //Chat Room Page
    TAPComponentColorIconFilePlayMedia, //Chat Room Page
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
    TAPTextColorButtonInactiveLabel,
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
    TAPTextColorContactListUsername,
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
    TAPTextColorRightBubbleMessageTimestamp,
    TAPTextColorLeftBubbleMessageTimestamp,
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
    TAPTextColorCustomWebViewNavigationTitleLabel,
    TAPTextColorRoomAvatarSmallLabel,
    TAPTextColorRoomAvatarMediumLabel,
    TAPTextColorRoomAvatarLargeLabel,
    TAPTextColorRoomAvatarExtraLargeLabel,
    TAPTextColorVersionCode,
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
    TAPComponentFontContactListUsername,
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
    TAPComponentFontRightBubbleMessageTimestamp,
    TAPComponentFontLeftBubbleMessageTimestamp,
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
    TAPComponentFontRoomAvatarSmallLabel,
    TAPComponentFontRoomAvatarMediumLabel,
    TAPComponentFontRoomAvatarLargeLabel,
    TAPComponentFontRoomAvatarExtraLargeLabel,
    TAPComponentFontMentionListNameLabel,
    TAPComponentFontMentionListUsernameLabel,
    TAPComponentFontVersionCode,
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

- (UIColor *)getRandomDefaultAvatarBackgroundColorWithName:(NSString *)name;
- (NSString *)getInitialsWithName:(NSString *)name isGroup:(BOOL)isGroup;

@end

NS_ASSUME_NONNULL_END
