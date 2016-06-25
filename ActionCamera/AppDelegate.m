//
//  AppDelegate.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "AppDelegate.h"
#import "ACSocketService.h"
#import "CameraHAM.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ViewController2.h"


//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface AppDelegate ()
@property (nonatomic, strong) CameraHAM *cameraHAM;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *baseDir = paths.firstObject;
        NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
        DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory];
        DDFileLogger* fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
        fileLogger.maximumFileSize = (1024 * 1024 * 1); //  1 MB
        fileLogger.rollingFrequency = (60 * 60 * 24);   // 24 Hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
        
        [DDLog addLogger:fileLogger];
        
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:[UIColor clearColor] forFlag:DDLogFlagError];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] forFlag:DDLogFlagWarning];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] forFlag:DDLogFlagInfo];
        
        DDLogError(@"DDLog init.");
    });
    
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
    
    _cameraHAM = [CameraHAM shared];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [ViewController2 new];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
