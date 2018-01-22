//
//  AppDelegate.m
//  HaiLookGif
//
//  Created by Ios_Developer on 2018/1/11.
//  Copyright © 2018年 hai. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSLog(@"----%@",NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES));
    [self removeFile];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
//
//         //程序在10分钟内未被系统关闭或者强制关闭，则程序会调用此代码块，可以在这里做一些保存或者清理工作
//        [self removeFile];
////        NSLog(@"程序关闭");
//
//     }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSLog(@"程序关闭");
    [self removeFile];
}

#pragma mark ===== tool =====
-(void)removeFile//清楚本地缓冲带图片
{
    NSString *imgPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/imgData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (imgPath)
    {
        [fileManager removeItemAtPath:imgPath error:NULL];
    }
}

@end
