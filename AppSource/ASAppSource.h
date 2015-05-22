//
//  ASAppSource.h
//  ASAppSource
//
//  Created by DjangoZhang on 15/5/19.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASAppMetadata;

@interface ASAppSource : NSObject

@property (nonatomic, readonly) ASAppMetadata *currentAppMetadata;

+ (instancetype)sharedInstance;

@end
