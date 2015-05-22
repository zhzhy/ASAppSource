//
//  NSDictionary+ASNSDictionaryFilter.h
//  AppSource
//
//  Created by DjangoZhang on 15/5/22.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ASNSDictionaryFilter)

- (NSDictionary *)AS_subDictionaryWithKeys:(NSArray *)keys;
- (NSDictionary *)AS_replacOriginKey:(NSArray *)keys withReplacingKeys:(NSArray *)replacingKeys;
- (NSDictionary *)AS_filterOriginKey:(NSArray *)keys withfilterKeys:(NSArray *)filterKeys;

@end
