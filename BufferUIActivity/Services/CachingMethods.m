//
//  CachingMethods.m
//  Buffer
//
//  Created by Andrew Yates on 18/07/2012.
//
//

#import "CachingMethods.h"

@implementation CachingMethods


- (NSString *)offlineCachePath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cache = [paths objectAtIndex:0];
	NSString *BufferPath = [cache stringByAppendingPathComponent:@"Buffer"];
	
	// Check if the path exists, otherwise create it
	if (![fileManager fileExistsAtPath:BufferPath]) {
		[fileManager createDirectoryAtPath:BufferPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	return BufferPath;
}


// Avatars
- (BOOL)addAvatartoCacheforProfile:(NSString *)profileID fromURL:(NSString *)url {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    [UIImagePNGRepresentation(image) writeToFile:[[self offlineCachePath] stringByAppendingPathComponent:profileID] atomically:YES];
    
	return YES;
}


// Profiles
- (NSString *)cachedProfileListPath {
	NSString *cachedProfileListPath = [[self offlineCachePath] stringByAppendingPathComponent:@"BufferCachedProfileList.plist"];
    return cachedProfileListPath;
}

- (NSMutableArray *)getCachedProfiles {
	return [[NSArray arrayWithContentsOfFile:[self cachedProfileListPath]] mutableCopy];
}

- (void)cacheProfileList:(NSMutableArray *)profileList {
	[profileList writeToFile:[self cachedProfileListPath] atomically:YES];
}

-(void)removeCachedProfiles {
    [@[] writeToFile:[self cachedProfileListPath] atomically:YES];
}


// Configuration
- (NSString *)cachedConfigurationPath {
	NSString *cachedConfigurationPath = [[self offlineCachePath] stringByAppendingPathComponent:@"BufferCachedConfig.plist"];
    return cachedConfigurationPath;
}

- (NSMutableArray *)getCachedConfiguration {
    NSMutableDictionary *configDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[self cachedConfigurationPath]];
    
	return (NSMutableArray *)configDictionary;
}

- (void)cacheConfiguration:(NSMutableDictionary *)configuration {
    
	[configuration writeToFile:[self cachedConfigurationPath] atomically:YES];
    [self cacheNetworkIcons:configuration];
}

- (void)removeCachedConfiguration {
    [@[] writeToFile:[self cachedConfigurationPath] atomically:YES];
}

-(void)cacheNetworkIcons:(NSMutableDictionary *)configuration {
    
    NSArray *services = [configuration valueForKey:@"services"];
    
    for(NSString *service in services){
        for(NSString *type in [[services valueForKey:service] valueForKey:@"types"]){
            for (NSString *iconSize in [[[[[configuration valueForKey:@"services"] valueForKey:service] valueForKey:@"types"] valueForKey:type] valueForKey:@"icons"]) {
                
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[[[configuration valueForKey:@"services"] valueForKey:service] valueForKey:@"types"] valueForKey:type] valueForKey:@"icons"] valueForKey:iconSize]]]];
                
                [UIImagePNGRepresentation(image) writeToFile:[[self offlineCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %@", [[[[[configuration valueForKey:@"services"] valueForKey:service] valueForKey:@"types"] valueForKey:type] valueForKey:@"name"], iconSize]] atomically:YES];
            }
        }
    }
    
}


@end
