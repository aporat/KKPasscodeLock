//
//  NSBundle+KKPasscodeLockAdditions.m
//  KKPasscodeLockDemo
//
//  Created by Hannes Käufler on 08.11.12.
//  Copyright (c) 2012 Kosher Penguin LLC. All rights reserved.
//

#import "NSBundle+KKPasscodeLockAdditions.h"

@implementation NSBundle (KKPasscodeLockAdditions)

+ (NSBundle *)KKPasscodeLockBundle {
	static NSBundle *bundle = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"KKPasscodeLock.bundle"];
		bundle = [[NSBundle alloc] initWithPath:bundlePath];
	});
	return bundle;
}

@end
