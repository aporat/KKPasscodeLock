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

#import "KKPasscodeSettingsViewController.h"
#import "KKKeychain.h"
#import "KKPasscodeViewController.h"
#import "SettingsViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation KKPasscodeSettingsViewController


@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = @"Passcode Lock";
  
  _simplePasscodeSwitch = [[UISwitch alloc] init];
  [_simplePasscodeSwitch addTarget:self action:@selector(simplePasscodeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
  
  _eraseDataSwitch = [[UISwitch alloc] init];
  [_eraseDataSwitch addTarget:self action:@selector(eraseDataSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  _passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"];
  _simplePasscodeOn = [[KKKeychain getStringForKey:@"passcode_lock_simple_passcode_on"] isEqualToString:@"YES"];
  _eraseDataOn = [[KKKeychain getStringForKey:@"passcode_lock_erase_data_on"] isEqualToString:@"YES"];
  _simplePasscodeSwitch.on = _simplePasscodeOn;
  _eraseDataSwitch.on = _eraseDataOn;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISwitch

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)simplePasscodeSwitchChanged:(id)sender
{
  _simplePasscodeOn = _simplePasscodeSwitch.on;
  if (_simplePasscodeOn) {
    [KKKeychain setString:@"YES" forKey:@"passcode_lock_simple_passcode_on"];
  } else {
    [KKKeychain setString:@"NO" forKey:@"passcode_lock_simple_passcode_on"];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    _eraseDataOn = YES;
    [KKKeychain setString:@"YES" forKey:@"passcode_lock_erase_data_on"];
  } else {
    _eraseDataOn = NO;
    [KKKeychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
  }
  [_eraseDataSwitch setOn:_eraseDataOn animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)eraseDataSwitchChanged:(id)sender {
  if (_eraseDataSwitch.on) {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"All data in this app will be erased after 10 failed passcode attempts." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Enable" otherButtonTitles:nil];
    [sheet showInView:self.view];
    [sheet release];
  } else {
    _eraseDataOn = NO;
    [KKKeychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
  }    
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table view data source


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 4;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  if (section == 2) {
    return @"A simple passcode is a 4 digit number.";
  } else if (section == 3) {
    return @"Erase all data in this app after 10 failed passcode attempts.";
  } else {
    return @"";
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  if (indexPath.section == 0) {
    if (_passcodeLockOn) {
      cell.textLabel.text = @"Turn Passcode Off";
    } else {
      cell.textLabel.text = @"Turn Passcode On";
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else if (indexPath.section == 1) {
    cell.textLabel.text = @"Change Passcode";
    if (_passcodeLockOn) {
      cell.textLabel.textColor = [UIColor blackColor];
      cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
      cell.textLabel.textColor = [UIColor grayColor];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.accessoryView = nil;
  } else if (indexPath.section == 2) {
    cell.textLabel.text = @"Simple Passcode";
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.accessoryView = _simplePasscodeSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_passcodeLockOn) {
      cell.textLabel.textColor = [UIColor grayColor];
      _simplePasscodeSwitch.enabled = NO;
    } else {
      cell.textLabel.textColor = [UIColor blackColor];
      _simplePasscodeSwitch.enabled = YES;
    }
  } else if (indexPath.section == 3) {
    cell.textLabel.text = @"Erase Data";
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.accessoryView = _eraseDataSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_passcodeLockOn) {
      cell.textLabel.textColor = [UIColor blackColor];
      _eraseDataSwitch.enabled = YES;
    } else {
      cell.textLabel.textColor = [UIColor grayColor];
      _eraseDataSwitch.enabled = NO;
    }
  }
  
  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table view delegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil 
                                                                              bundle:nil];
    vc.delegate = self;
    
    if (_passcodeLockOn) {
      vc.mode = KKPasscodeModeDisabled;
    } else {
      vc.mode = KKPasscodeModeSet;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      vc.modalPresentationStyle = UIModalPresentationFormSheet;
    }                
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      nav.modalPresentationStyle = UIModalPresentationFormSheet;
      nav.navigationBar.barStyle = UIBarStyleBlack;
      nav.navigationBar.opaque = NO;
    } else {
      nav.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
      nav.navigationBar.translucent = self.navigationController.navigationBar.translucent;
      nav.navigationBar.opaque = self.navigationController.navigationBar.opaque;
      nav.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;    
    }
    
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    
    
    [vc release];
  } else if (indexPath.section == 1 && _passcodeLockOn) {
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:@"KKPasscodeViewController" bundle:nil];
    vc.delegate = self;
    
    vc.mode = KKPasscodeModeChange;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      vc.modalPresentationStyle = UIModalPresentationFormSheet;
    }                
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      nav.modalPresentationStyle = UIModalPresentationFormSheet;
      nav.navigationBar.barStyle = UIBarStyleBlack;
      nav.navigationBar.opaque = NO;
    } else {
      nav.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
      nav.navigationBar.translucent = self.navigationController.navigationBar.translucent;
      nav.navigationBar.opaque = self.navigationController.navigationBar.opaque;
      nav.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;    
    }
    
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    
    [vc release];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSettingsChanged:(KKPasscodeViewController*)viewController {
  [self.tableView reloadData];

  NSLog(@"OKOKO");
  if ([_delegate respondsToSelector:@selector(didSettingsChanged::)]) {
    [_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
  }
  
  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory management


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
  [_simplePasscodeSwitch release];
  [_eraseDataSwitch release];

  [super dealloc];
}


@end

