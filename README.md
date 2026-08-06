# TapTalk.io iOS SDK
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C-orange.svg)

## Introduction
[TapTalk.io](https://taptalk.io) is a complete in-app chat SDK and messaging API. Its in-app chat features give you and your user the best in-app chat experience, providing fully customizable UI-based implementation and code-based implementations.

## Getting TapTalk.io SDK (Swift Package Manager)
From version 3.0.0 and above, TapTalk.io SDK is available in Swift Package Manager. 

### Installation
1. To add TapTalk.io package to your project, open your project in Xcode, then go to menu bar then select **File -> Add Package Dependencies**, then enter https://github.com/taptalk-io/taptalk.io-ios in the top right search bar.
2. Specify the version and target, then click **Add Package**.
3. After the package is resolved, select your project from the Project navigator (folder icon at the top left pane), click the required target, go to **General** tab and make sure **PowerTalk** is added to Frameworks and Libraries, if not, add it with the **+** button, then add PowerTalk from TapTalk Package.
4. Check out the samples or follow the **Quick Start & Documentation** guide to start using it in your project.

## Getting TapTalk.io SDK (Cocoapods)

### Dependencies
Since TapTalk.io SDK uses `git-lfs`, you will need to install it to clone/install TapTalk.io SDK through **Cocoapods**.
Easiest way to install [git-lfs](https://git-lfs.github.com) is using [brew](https://brew.sh):
```
brew install git-lfs
git lfs install
```

### Installation
1. **Install git-lfs**
2. Add `pod 'TapTalk'` to your podfile
3. Run `pod install`
4. Check out the samples or follow the **Quick Start & Documentation** guide to start using it in your project.

## Quick Start & Documentation
For more information about the documentation, please refer to this [documentation page](https://docs.taptalk.io/powertalk-chat-sdk-documentation/powertalk-ios).
