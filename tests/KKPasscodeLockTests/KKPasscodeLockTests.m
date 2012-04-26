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

#import "KKPasscodeLockTests.h"
#import "KKPasscodeLock.h"

@implementation KKPasscodeLockTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDefaultSettings
{
  KKPasscodeLock* sharedLock = [KKPasscodeLock sharedLock];
  
  STAssertEquals(sharedLock.eraseOption, YES, @"Erase option is default to YES");
  STAssertEquals(sharedLock.attemptsAllowed, (NSUInteger)5, @"attemptsAllowed default to 5 tries");
  
    
}

@end
