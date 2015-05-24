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

- (NSString *)iTunesMediaPath {
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"iTunesMetadata.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"iTunesMetadata" ofType:@"plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return nil;
        }
    }
    
    return filePath;
}

- (NSDictionary *)iTunesMediaInfo {
    NSString *iTunesMediaPath = [self iTunesMediaPath];
    if ([iTunesMediaPath length] > 0) {
        return [NSDictionary dictionaryWithContentsOfFile:iTunesMediaPath];
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
                    return provisionInfo;
                }
            }
        }
    }
    
    return nil;
}

- (ASAppReleaseMode)releaseMode:(NSDictionary *)mobileProvisionInfo {
    ASAppReleaseMode releaseMode;
    if (mobileProvisionInfo == nil) {
        releaseMode = ASAppReleaseModeUnknow;
    }else if ([mobileProvisionInfo count] == 0) {
#ifdef TARGET_IPHONE_SIMULATOR
        releaseMode = ASAppReleaseModeSimulator;
#else
        releaseMode = ASAppReleaseModeAppStore;
#endif
    }else if ([mobileProvisionInfo[@"ProvisionsAllDevices"] boolValue]) {
        releaseMode = ASAppReleaseModeEnterprise;
    }else if ([mobileProvisionInfo[@"ProvisionedDevices"] count] > 0) {
        if ([mobileProvisionInfo[@"Entitlements"][@"get-task-allow"] boolValue]) {
            releaseMode = ASAppReleaseModeDevelop;
        }else {
            releaseMode = ASAppReleaseModeAdHoc;
        }
    }else {
        releaseMode = ASAppReleaseModeAppStore;
    }
    
    return releaseMode;
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
    ASAppReleaseMode releaseMode = [self releaseMode:mobileProvisionInfo];
    
    NSDictionary *reducedProvisionInfo = [mobileProvisionInfo AS_subDictionaryWithKeys:@[kAppMarket, kRedownload]];
    NSMutableDictionary *filterProvisionInfo = [NSMutableDictionary dictionaryWithDictionary:reducedProvisionInfo];
    [filterProvisionInfo setObject:@(releaseMode) forKey:kReleaseMode];
    
    return filterProvisionInfo;
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
