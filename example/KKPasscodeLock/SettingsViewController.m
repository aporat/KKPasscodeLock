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

#import "SettingsViewController.h"
#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"

@implementation SettingsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)doneButtonPressed:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"Settings";
  
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
  
  self.navigationItem.rightBarButtonItem = doneButton;
  [doneButton release];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  
  if (indexPath.section == 0) {
    cell.textLabel.text = @"Passcode Lock";
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
      cell.detailTextLabel.text = @"On";
    } else {
      cell.detailTextLabel.text = @"Off";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } 
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    KKPasscodeSettingsViewController *vc = [[[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
  } 
}

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController
{
  [self.tableView reloadData];
}

@end
