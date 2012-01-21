//
// Copyright 2011-2012 Kosher Penguin LLC 
// Created by Adar Porat (https://github.com/aporat) on 1/16/2012.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "KKPasscodeLock.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController=_navigationController;

- (void)dealloc
{
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  [[KKPasscodeLock sharedLock] setDefaultSettings];
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.window.backgroundColor = [UIColor whiteColor];
  
  RootViewController* vc = [[[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil] autorelease];
  
  _navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
  [self.window addSubview:_navigationController.view];  
  [self.window makeKeyAndVisible];
  
  return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
  if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
    KKPasscodeViewController *vc = [[[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    vc.mode = KKPasscodeModeEnter;
    vc.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(),^ {
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
      
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.opaque = NO;
      } else {
        nav.navigationBar.tintColor = _navigationController.navigationBar.tintColor;
        nav.navigationBar.translucent = _navigationController.navigationBar.translucent;
        nav.navigationBar.opaque = _navigationController.navigationBar.opaque;
        nav.navigationBar.barStyle = _navigationController.navigationBar.barStyle;    
      }
      
      [_navigationController presentModalViewController:nav animated:YES];
    });
    
  }
}

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController 
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController 
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
  [alert release];}


@end
