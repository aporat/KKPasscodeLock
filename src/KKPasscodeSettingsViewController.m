//
// Copyright 2011-2012 Kosher Penguin LLC
// Created by Adar Porat (https://github.com/aporat) on 1/16/2012.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
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
#import "KKPasscodeLock.h"


@implementation KKPasscodeSettingsViewController


@synthesize delegate = _delegate;

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = KKPasscodeLockLocalizedString(@"Passcode Lock", @"");
    
	_eraseDataSwitch = [[UISwitch alloc] init];
	[_eraseDataSwitch addTarget:self action:@selector(eraseDataSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
    _eraseDataSwitch = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	_passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_on"] isEqualToString:@"YES"];
	_eraseDataOn = [[KKKeychain getStringForKey:@"erase_data_on"] isEqualToString:@"YES"];
	_eraseDataSwitch.on = _eraseDataOn;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		_eraseDataOn = YES;
		[KKKeychain setString:@"YES" forKey:@"erase_data_on"];
	} else {
		_eraseDataOn = NO;
		[KKKeychain setString:@"NO" forKey:@"erase_data_on"];
	}
	[_eraseDataSwitch setOn:_eraseDataOn animated:YES];
}

- (void)eraseDataSwitchChanged:(id)sender
{
	if (_eraseDataSwitch.on) {
		NSString* title = [NSString stringWithFormat:KKPasscodeLockLocalizedString(@"All data in this app will be erased after %d failed passcode attempts.", @""), [[KKPasscodeLock sharedLock] attemptsAllowed]];
		
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:KKPasscodeLockLocalizedString(@"Cancel", @"") destructiveButtonTitle:KKPasscodeLockLocalizedString(@"Enable", @"") otherButtonTitles:nil];
		[sheet showInView:self.view];
	} else {
		_eraseDataOn = NO;
		[KKKeychain setString:@"NO" forKey:@"erase_data_on"];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([[KKPasscodeLock sharedLock] eraseOption]) {
		return 2;
	}
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 1) {
		return [NSString stringWithFormat:KKPasscodeLockLocalizedString(@"Erase all content in the app after %d failed passcode attempts.", @""), [[KKPasscodeLock sharedLock] attemptsAllowed]];;
	} else {
		return @"";
	}
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *CellIdentifier = @"KKPasscodeSettingsCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    cell.textLabel.textAlignment = UITextAlignmentLeft;
#else
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
#endif
    
    cell.textLabel.textColor = [UIColor blackColor];
    
	
	if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            cell.textLabel.textAlignment = UITextAlignmentCenter;
#else
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
#endif
            
            if (_passcodeLockOn) {
                cell.textLabel.text = KKPasscodeLockLocalizedString(@"Turn Passcode Off", @"");
            } else {
                cell.textLabel.text = KKPasscodeLockLocalizedString(@"Turn Passcode On", @"");
            }
        } else {
            cell.textLabel.text = KKPasscodeLockLocalizedString(@"Change Passcode", @"");
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            cell.textLabel.textAlignment = UITextAlignmentCenter;
#else
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
#endif
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!_passcodeLockOn) {
                cell.textLabel.textColor = [UIColor grayColor];
            }
            
        }
	} else if (indexPath.section == 1) {
		cell.textLabel.text = KKPasscodeLockLocalizedString(@"Erase Data", @"");
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

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 0) {
		KKPasscodeViewController* vc = [[KKPasscodeViewController alloc] initWithNibName:nil
                                                                                  bundle:nil];
		vc.delegate = self;
		
		if (_passcodeLockOn) {
			vc.mode = KKPasscodeModeDisabled;
		} else {
			vc.mode = KKPasscodeModeSet;
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
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        [self.navigationController presentModalViewController:nav animated:YES];
#else
        [self.navigationController presentViewController:nav animated:YES completion:nil];
#endif
		
	} else if (indexPath.section == 0 && indexPath.row == 1 && _passcodeLockOn) {
		KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
		vc.delegate = self;
		
		vc.mode = KKPasscodeModeChange;
		
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
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        [self.navigationController presentModalViewController:nav animated:YES];
#else
        [self.navigationController presentViewController:nav animated:YES completion:nil];
#endif
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)didSettingsChanged:(KKPasscodeViewController*)viewController
{
	_passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_on"] isEqualToString:@"YES"];
	_eraseDataOn = [[KKKeychain getStringForKey:@"erase_data_on"] isEqualToString:@"YES"];
	_eraseDataSwitch.on = _eraseDataOn;
    
	[self.tableView reloadData];
	
	if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
		[_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
	}
	
}


@end

