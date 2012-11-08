//
//  NSBundle+KKPasscodeLockAdditions.h
//  KKPasscodeLockDemo
//
//  Created by Hannes Käufler on 08.11.12.
//  Copyright (c) 2012 Kosher Penguin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KKPasscodeLockLocalizedString(key, comment) [[NSBundle KKPasscodeLockBundle] localizedStringForKey:(key) value:@"" table:@"KKPasscodeLock"]

@interface NSBundle (KKPasscodeLockAdditions)

+(NSBundle *)KKPasscodeLockBundle;

@end
