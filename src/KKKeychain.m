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

#import "KKKeychain.h"
#import <Security/Security.h>

@implementation KKKeychain

+ (NSString*)appName
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (!appName) {
		appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
	}
	return appName;
}

+ (BOOL)setString:(NSString*)string forKey:(NSString*)key
{
	if (string == nil || key == nil) {
		return NO;
	}
	
	key = [NSString stringWithFormat:@"%@ - %@", [KKKeychain appName], key];
    
	// First check if it already exists, by creating a search dictionary and requesting that
	// nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	[existsQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
    
    OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef) existsQueryDictionary, NULL);
    
	if (res == errSecItemNotFound) {
		if (string != nil) {
			NSMutableDictionary *addDict = existsQueryDictionary;
			[addDict setObject:data forKey:(__bridge id)kSecValueData];
            
			res = SecItemAdd((__bridge CFDictionaryRef)addDict, NULL);
			NSAssert1(res == errSecSuccess, @"Recieved %ld from SecItemAdd!", (long) res);
		}
	} else if (res == errSecSuccess) {
		// Modify an existing one
		// Actually pull it now of the keychain at this point.
		NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:data forKey:(__bridge id)kSecValueData];
		res = SecItemUpdate((__bridge CFDictionaryRef)existsQueryDictionary, (__bridge CFDictionaryRef)attributeDict);
		NSAssert1(res == errSecSuccess, @"SecItemUpdated returned %ld!", (long) res);
	} else {
		NSAssert1(NO, @"Received %ld from SecItemCopyMatching!", (long) res);
	}
	return YES;
}

+ (NSString*)getStringForKey:(NSString*)key
{
	key = [NSString stringWithFormat:@"%@ - %@", [KKKeychain appName], key];
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	[existsQueryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// Add the keys to the search dict
	[existsQueryDictionary setObject:@"service" forKey:(__bridge id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(__bridge id)kSecAttrAccount];
	
	// We want the data back!
	CFTypeRef data = nil;
	
	[existsQueryDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
	OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)existsQueryDictionary, &data);
    
	if (res == errSecSuccess) {
		NSString *string = [[NSString alloc] initWithData:(__bridge NSData*)data encoding:NSUTF8StringEncoding];
		return string;
	} else {
		NSAssert1(res == errSecItemNotFound, @"SecItemCopyMatching returned %ld!", (long) res);
	}
	
	return nil;
}


@end
