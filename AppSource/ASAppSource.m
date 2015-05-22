//
//  ASAppSource.m
//  ASAppSource
//
//  Created by DjangoZhang on 15/5/19.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import "ASAppSource.h"
#import "ASAppMetadata.h"
#import "NSDictionary+ASNSDictionaryFilter.h"

@interface ASAppSource ()

@property (nonatomic, readwrite) ASAppMetadata *currentAppMetadata;
@property (nonatomic) NSMutableDictionary *currentAppMetadataInfo;
@property (nonatomic) NSLock *currentAppMetadataLock;

@end

@implementation ASAppSource

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _currentAppMetadataLock = [[NSLock alloc] init];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static ASAppSource *sharedAppSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppSource = [[ASAppSource alloc] init];
    });
    
    return sharedAppSource;
}

- (NSDictionary *)iTunesMediaInfo {
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"iTunesMetadata.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    
    return @{};
}

- (NSDictionary *)mobileProvisionInfo {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (filePath != 0) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSISOLatin1StringEncoding error:NULL];
        if ([contents length] > 0) {
            NSRange plistBegin = [contents rangeOfString:@"<plist"];
            NSRange plistEnd = [contents rangeOfString:@"</plist>"];
            if (plistBegin.length > 0 &&
                plistEnd.length > 0 &&
                plistEnd.location > plistBegin.location) {
                NSString *plistString = [contents substringWithRange:NSMakeRange(plistBegin.location, plistEnd.location - plistBegin.location + plistEnd.length)];
                if ([plistString length] > 0) {
                    NSData *plistData = [plistString dataUsingEncoding:NSISOLatin1StringEncoding];
                    NSDictionary *provisionInfo = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:NULL];
                    if (provisionInfo != nil) {
                        return provisionInfo;
                    }
                }
            }
        }
    }
    
    return @{};
}

- (NSDictionary *)filteriTunesMediaInfo {
    NSDictionary *iTunesMediaInfo = [self iTunesMediaInfo];
    
    NSDictionary *filteriTunesMediaInfo = [iTunesMediaInfo AS_filterOriginKey:@[@"sourceApp",
                                                                                @"is-purchased-redownload"]
                                                               withfilterKeys:@[kAppMarket, kRedownload]];
    NSString *AppleID = iTunesMediaInfo[@"com.apple.iTunesStore.downloadInfo"][@"accountInfo"][@"AppleID"];
    if ([AppleID length] > 0) {
        NSMutableDictionary *mergediTunesMeidaInfo = [NSMutableDictionary dictionaryWithDictionary:filteriTunesMediaInfo];
        [mergediTunesMeidaInfo setObject:AppleID forKey:kPurchaseAccount];
        
        return mergediTunesMeidaInfo;
    }
    
    return filteriTunesMediaInfo;
}

- (NSDictionary *)filterMobileProvisionInfo {
    NSDictionary *mobileProvisionInfo = [self mobileProvisionInfo];
    
    return [mobileProvisionInfo AS_subDictionaryWithKeys:@[kAppMarket, kRedownload]];
}

- (ASAppMetadata *)currentAppMetadata {
    [self.currentAppMetadataLock lock];
    if (_currentAppMetadata == nil) {
        self.currentAppMetadataInfo = [NSMutableDictionary dictionaryWithDictionary:[self filteriTunesMediaInfo]];
        [self.currentAppMetadataInfo addEntriesFromDictionary:[self filterMobileProvisionInfo]];
        
        _currentAppMetadata = [[ASAppMetadata alloc] initWithDictionary:self.currentAppMetadataInfo];
    }
    
    [self.currentAppMetadataLock unlock];
    
    return _currentAppMetadata;
}



@end
