/*
     File: AppDelegate.m
 Abstract: Application delegate
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constant.h"
@implementation AppDelegate
@synthesize alertView;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self checkInternetConnection];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:isFirstTime])
    {
        UIStoryboard* storyboard   = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"vController"];
        self.window.rootViewController = vc;

    }
    else
    {
        UIStoryboard* storyboard   = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UITabBarController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
        self.window.rootViewController = tabBar;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark -
#pragma mark Richability check
-(void)checkInternetConnection
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    self.hostReach = [Reachability reachabilityWithHostname:@"www.google.com"] ;
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(curReach == self.hostReach)
    {
        switch (netStatus)
        {
            case NotReachable:
            {
                self.isInternetAvailable = NO;
                break;
            }
            case ReachableViaWWAN:
            {
                self.isInternetAvailable = YES;
                break;
            }
            case ReachableViaWiFi:
            {
                //DLog(@"Reachable WiFi");
                self.isInternetAvailable = YES;
                break;
            }
        }
    }
    if(curReach == self.internetReach || curReach == self.wifiReach)
    {
        //DLog(@"internetReach");
        self.isInternetAvailable = YES;
        
    }
}
#pragma mark -
#pragma mark No connection alert
-(void)showInternetNotAvailableAlert
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please check internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
@end

