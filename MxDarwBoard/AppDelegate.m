//
//  AppDelegate.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/15.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MxMeshManager.h"
#import "MxDrawBoardManager.h"
#import "MxDrawBoardViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [self saveLog];
    [MxDrawBoardManager.shareInstance getAllPoint];
    [MxMeshManager setupWithConfig:nil];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MxDrawBoardViewController * rootVC = [[MxDrawBoardViewController alloc] init];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

//仅支持横屏
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskLandscape;
    }
//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    return isPhone() ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskAll;
//    }
//    BOOL isPhone(void)
//    {
//    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
//}

-(void)saveLog{

        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"Simulator"]) {
            return;
        }

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

        NSString *documentDirectory = [paths objectAtIndex:0];

        NSString *fileName = [NSString stringWithFormat:@"MxDrawBoard.log"];

        NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];

        // Delete existing files
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:logFilePath error:nil];

        //Enter the log into the file
        freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
        freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);


}

@end
