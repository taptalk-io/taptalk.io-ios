//
//  TAPAudioManager.m
//  TapTalk
//
//  Created by TapTalk.io on 05/04/22.
//

#import "TAPAudioManager.h"
#import <AVFoundation/AVFoundation.h>

@interface TAPAudioManager ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (nonatomic) NSString *filePath;
@end

@implementation TAPAudioManager

#pragma mark - Lifecycle
+ (TAPAudioManager *)sharedManager {
    static TAPAudioManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    if(self) {
    
    }
    return self;
}
#pragma mark - Delegate
#pragma mark - Audio Delegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    if ([self.delegate respondsToSelector:@selector(finishAudioRecord:AVRecorder:)]) {
        [self.delegate finishAudioRecord:self.recorder.url AVRecorder:avrecorder];
        
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [TAPDataManager setCurrentVoicePlayingFilePath:@""];
    if ([self.delegate respondsToSelector:@selector(finishAudioPlay)]) {
        [self.delegate finishAudioPlay];
    }
}



#pragma mark - Custom Method
- (void)starRecordAudio {
    if (self.player.playing) {
        [self.player stop];
        
    }
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];

        // Start recording
        [self.recorder record];
        
    }
    else{
        // Pause recording
        [self.recorder pause];
    }
    
}

- (void)stopRecordAudio {
    [self.recorder stop];
}

- (void)stopPlayer {
    [TAPDataManager setCurrentVoicePlayingFilePath:@""];
    [self.player stop];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)pausePlayer {
    [TAPDataManager setCurrentVoicePlayingFilePath:@""];
    [self.player pause];
}

- (void)resumePlayer {
    [TAPDataManager setCurrentVoicePlayingFilePath:self.filePath];
    if ([self.delegate respondsToSelector:@selector(startAudioPlay:)]) {
        [self.delegate startAudioPlay:self.player.duration];
    }
    [self.player play];
}

- (void)playAudio:(NSString *)filePath {
    self.filePath = filePath;
    [TAPDataManager setCurrentVoicePlayingFilePath:filePath];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory :AVAudioSessionCategoryPlayback error:nil];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url fileTypeHint:AVFileTypeMPEG4 error:&error];
    [self.player setDelegate:self];
    
    if ([self.delegate respondsToSelector:@selector(startAudioPlay:)]) {
        [self.delegate startAudioPlay:self.player.duration];
    }


    [self.player play];
}

- (void)setupPlayerAudio:(NSString *)filePath {
    self.filePath = filePath;
    [TAPDataManager setCurrentVoicePlayingFilePath:filePath];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory :AVAudioSessionCategoryPlayback error:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player setDelegate:self];
    
    
}

- (void)setPlayerCurrentTime:(NSTimeInterval)currentTime{
    self.player.currentTime = currentTime;
}

- (NSTimeInterval)getPlayerCurrentTime{
    return self.player.currentTime;
}

- (NSTimeInterval)getPlayerDuration{
    return self.player.duration;
}

- (NSString *)getPlayerCurrentFilePath{
    return self.player.url.path;
}

- (BOOL)checkAudioPermissionAndSetup {
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            [self setupAudioManager];
            return YES;
            break;
        case AVAudioSessionRecordPermissionDenied:
            return NO;
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            return NO;
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        NSLog(@"Permission granted");
                    }
                    else {
                        NSLog(@"Permission denied");
                    }
                }];
            break;
        default:
            return NO;
            break;
    }
}

- (void)setupAudioManager {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-d-H:m:s"];

    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.m4a", dateString];
    
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], fileName, nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [session setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
       // NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [session setActive:YES error:&err];
    err = nil;
    if(err){
       // NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    

    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self. recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}



@end
