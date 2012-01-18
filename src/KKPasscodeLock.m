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

#import "KKPasscodeLock.h"
#import "KKKeychain.h"
#import "KKPasscodeViewController.h"

static KKPasscodeLock *sharedLock = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation KKPasscodeLock


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (KKPasscodeLock*)sharedLock
{
  @synchronized(self) {
    if (sharedLock == nil) {
      sharedLock = [[self alloc] init];
    }
  }
  return sharedLock;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDefaultSettings
{
  if (![KKKeychain getStringForKey:@"passcode_lock_passcode_on"]) {
    [KKKeychain setString:@"NO" forKey:@"passcode_lock_passcode_on"];
  }
  
  if (![KKKeychain getStringForKey:@"passcode_lock_simple_passcode_on"]) {
    [KKKeychain setString:@"YES" forKey:@"passcode_lock_simple_passcode_on"];
  }
  
  if (![KKKeychain getStringForKey:@"passcode_lock_erase_data_on"]) {
    [KKKeychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isPasscodeRequired
{
  return [[KKKeychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentAndRelease:(NSTimer *)timer
{
  UIViewController *vc = [timer.userInfo objectForKey:@"vc"];
  UINavigationController *navController = [timer.userInfo objectForKey:@"nav"];
  
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.opaque = NO;
  } else {
    nav.navigationBar.tintColor = navController.navigationBar.tintColor;
    nav.navigationBar.translucent = navController.navigationBar.translucent;
    nav.navigationBar.opaque = navController.navigationBar.opaque;
    nav.navigationBar.barStyle = navController.navigationBar.barStyle;    
  }
  
  [navController presentModalViewController:nav animated:YES];
  [nav release];
  
  
  [vc release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPasscodeController:(UINavigationController*)navController
{
  if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    vc.mode = KKPasscodeModeEnter;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      vc.modalPresentationStyle = UIModalPresentationFullScreen;
    }                
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      for (UIViewController *svc in navController.viewControllers) {
        svc.view.alpha = 0.0;
      }
      
      NSDictionary* userinfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"vc", vc, 
                                @"nav", navController, nil];
      
      [NSTimer scheduledTimerWithTimeInterval:0.3 target:self 
                                     selector:@selector(presentAndRelease:) userInfo:
       userinfo repeats:NO];
      
    } else {
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
      
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.opaque = NO;
      } else {
        nav.navigationBar.tintColor = navController.navigationBar.tintColor;
        nav.navigationBar.translucent = navController.navigationBar.translucent;
        nav.navigationBar.opaque = navController.navigationBar.opaque;
        nav.navigationBar.barStyle = navController.navigationBar.barStyle;    
      }
      
      [navController presentModalViewController:nav animated:NO];
      [nav release];
      [vc release];
    }
  }
}


@end
