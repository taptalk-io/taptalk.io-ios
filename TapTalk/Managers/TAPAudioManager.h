//
//  TAPAudioManager.h
//  TapTalk
//
//  Created by TapTalk.io on 05/04/22.
//

#import <Foundation/Foundation.h>

@protocol TAPAudioManagerDelegate <NSObject>
@optional
- (void)finishAudioRecord:(NSURL *)url AVRecorder:(AVAudioRecorder *)avrecorder;
- (void)finishAudioPlay;
- (void)startAudioPlay:(NSTimeInterval)duration;
@end

@interface TAPAudioManager : NSObject

@property (weak, nonatomic) id<TAPAudioManagerDelegate> delegate;

+ (TAPAudioManager *)sharedManager;

- (BOOL)checkAudioPermissionAndSetup;
- (void)starRecordAudio;
- (void)stopRecordAudio;
- (void)playAudio:(NSString *)filePath;
- (NSTimeInterval)getPlayerCurrentTime;
- (BOOL)isPlaying;
- (void)pausePlayer;
- (void)resumePlayer;
- (void)stopPlayer;
- (void)setupPlayerAudio:(NSString *)filePath;
- (BOOL)isRecording;
- (NSString *)getPlayerCurrentFilePath;
- (void)setPlayerCurrentTime:(NSTimeInterval)currentTime;
- (NSTimeInterval)getPlayerDuration;

@end

