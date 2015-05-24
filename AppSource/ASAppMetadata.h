//
//  ASAppMetadata.h
//  AppSource
//
//  Created by DjangoZhang on 15/5/20.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define String(name) @#name
#define StringValue(value) String(value)

#define Redownload redownload
#define PurchaseAccount purchaseAccount
#define AppMarket AppMarket
#define AppIDName AppIDName
#define TeamName teamName
#define ReleaseMode releaseMode

#define kRedownload StringValue(Redownload)
#define kPurchaseAccount StringValue(PurchaseAccount)
#define kAppMarket StringValue(AppMarket)
#define kAppIDName StringValue(AppIDName)
#define kTeamName StringValue(teamName)
#define kReleaseMode StringValue(ReleaseMode)

typedef NS_ENUM(NSInteger, ASAppReleaseMode) {
    ASAppReleaseModeUnknow,
    ASAppReleaseModeSimulator,
    ASAppReleaseModeDevelop,
    ASAppReleaseModeEnterprise,
    ASAppReleaseModeAdHoc,
    ASAppReleaseModeAppStore
};

@interface ASAppMetadata : NSObject

@property (nonatomic, readonly) BOOL Redownload;
@property (nonatomic, readonly) NSString *PurchaseAccount;
@property (nonatomic, readonly) NSString *AppMarket;
@property (nonatomic, readonly) NSString *AppIDName;
@property (nonatomic, readonly) NSString *TeamName;
@property (nonatomic, readonly) ASAppReleaseMode ReleaseMode;
@property (nonatomic, readonly) NSDictionary *descriptionInfo;

- (instancetype)initWithDictionary:(NSDictionary *)AppMetadataInfo;

@end
