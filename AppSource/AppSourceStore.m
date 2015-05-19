//
//  AppSourceStore.m
//  AppSource
//
//  Created by DjangoZhang on 15/5/19.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import "AppSourceStore.h"

@interface AppSourceStore ()

@property (nonatomic, strong) NSDictionary *itunesMedias;
@end

@implementation AppSourceStore

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        NSString *itunesMediaPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
        if ([itunesMediaPath length] > 0) {
            _itunesMedias = [NSDictionary dictionaryWithContentsOfFile:itunesMediaPath];
        }
    }
    
    return self;
}

- (NSString *)storeName {
    return self.itunesMedias[@""];
}

- (BOOL)isFromAppStore {
    if ([[self storeName] isEqual:@"AppStore"] &&
        self.itunesMedias[@"com.apple.iTunesStore.downloadInfo"][@"accountInfo"][@"AppleID"]) {
        return YES;
    }
    
    return NO;
}

@end
