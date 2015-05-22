//
//  ASAppMetadata.m
//  AppSource
//
//  Created by DjangoZhang on 15/5/20.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import "ASAppMetadata.h"

@interface ASAppMetadata ()

@property (nonatomic, readwrite) BOOL Redownload;
@property (nonatomic, readwrite) NSString *PurchaseAccount;
@property (nonatomic, readwrite) NSString *AppMarket;
@property (nonatomic, readwrite) NSString *AppIDName;
@property (nonatomic, readwrite) NSString *TeamName;
@property (nonatomic, readwrite) NSDictionary *descriptionInfo;

@end

@implementation ASAppMetadata

- (instancetype)initWithDictionary:(NSDictionary *)AppMetadataInfo {
    self = [super init];
    if (self != nil) {
        [self setValuesForKeysWithDictionary:AppMetadataInfo];
        _descriptionInfo = [AppMetadataInfo copy];
    }
    
    return self;
}

@end
