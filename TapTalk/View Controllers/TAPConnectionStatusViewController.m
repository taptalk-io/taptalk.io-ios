//
//  TAPConnectionStatusViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 8/10/18.
//

#import "TAPConnectionStatusViewController.h"
#import "TAPConnectionStatusView.h"
#import <AFNetworking/AFNetworking.h>

@interface TAPConnectionStatusViewController ()

@property (strong, nonatomic) TAPConnectionStatusView *connectionStatusView;
@property (nonatomic) TAPConnectionManagerStatusType statusType;

@end

@implementation TAPConnectionStatusViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _connectionStatusView = [[TAPConnectionStatusView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.connectionStatusView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 0.0f);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnectedNotification:) name:TAP_NOTIFICATION_SOCKET_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnectingNotification:) name:TAP_NOTIFICATION_SOCKET_CONNECTING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        _statusType = [TAPConnectionManager sharedManager].tapConnectionStatus;
        if(self.statusType == TAPConnectionManagerStatusTypeNotConnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
        }
        else if (self.statusType == TAPConnectionManagerStatusTypeDisconnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeConnecting];
        }
        else if (self.statusType == TAPConnectionManagerStatusTypeConnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
        }
        else if (self.statusType == TAPConnectionManagerStatusTypeConnecting) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeConnecting];
        }
        else {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
        }
    }
    else {
        [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeOffline];
    }
    
    
    [self checkStatusHeight];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_SOCKET_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_SOCKET_CONNECTING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
}

#pragma mark - Custom Method
- (void)checkStatusHeight {
    CGFloat viewHeight = 0.0f;
    if ([TAPConnectionManager sharedManager].tapConnectionStatus != TAPConnectionManagerStatusTypeConnected && [TAPConnectionManager sharedManager].tapConnectionStatus != TAPConnectionManagerStatusTypeNotConnected) {
        viewHeight = 20.0f;
    }
    
    if ([TAPConnectionManager sharedManager].tapConnectionStatus == TAPConnectionManagerStatusTypeConnected) {
        [UIView animateWithDuration:0.2f delay:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
            self.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), viewHeight);
            
        } completion:^(BOOL finished) {
            //do nothing
            if ([self.delegate respondsToSelector:@selector(connectionStatusViewControllerDelegateHeightChange:)]) {
                [self.delegate connectionStatusViewControllerDelegateHeightChange:viewHeight];
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), viewHeight);
            if ([self.delegate respondsToSelector:@selector(connectionStatusViewControllerDelegateHeightChange:)]) {
                [self.delegate connectionStatusViewControllerDelegateHeightChange:viewHeight];
            }
        }];
    }
}

- (void)removeNetworkNotificationView {
    [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
    [self checkStatusHeight];
}

- (void)socketConnectingNotification:(NSNotification *)notification {
    if([AFNetworkReachabilityManager sharedManager].reachable) {
        [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeConnecting];
    }
    else {
        [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeOffline];
    }
    [self checkStatusHeight];
}

- (void)socketConnectedNotification:(NSNotification *)notification {
    [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeConnected];
    [self checkStatusHeight];
    [TAPUtil tapticNotificationFeedbackGeneratorWithType:UINotificationFeedbackTypeSuccess];
    [self performSelector:@selector(removeNetworkNotificationView) withObject:nil afterDelay:0.5f];
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    if([AFNetworkReachabilityManager sharedManager].reachable) {
        if([TAPConnectionManager sharedManager].tapConnectionStatus == TAPConnectionManagerStatusTypeNotConnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
        }
        else if ([TAPConnectionManager sharedManager].tapConnectionStatus == TAPConnectionManagerStatusTypeDisconnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeOffline];
        }
        else if ([TAPConnectionManager sharedManager].tapConnectionStatus == TAPConnectionManagerStatusTypeConnected) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeNone];
        }
        else if ([TAPConnectionManager sharedManager].tapConnectionStatus == TAPConnectionManagerStatusTypeConnecting) {
            [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeConnecting];
        }
    }
    else {
        [self.connectionStatusView setConnectionStatusType:TAPConnectionStatusTypeOffline];
    }
    
    [self checkStatusHeight];
}

@end
