//
//  NSDictionary+ASNSDictionaryFilter.m
//  AppSource
//
//  Created by DjangoZhang on 15/5/22.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import "NSDictionary+ASNSDictionaryFilter.h"

@implementation NSDictionary (ASNSDictionaryFilter)

- (NSDictionary *)AS_subDictionaryWithKeys:(NSArray *)keys {
    NSMutableSet *originKeys = [NSMutableSet setWithArray:[self allKeys]];
    NSMutableSet *replacingKeys = [NSMutableSet setWithArray:keys];
    [originKeys intersectSet:replacingKeys];
    
    NSArray *intersectedKeys = [originKeys allObjects];
    NSArray *replacingValues = [self objectsForKeys:intersectedKeys notFoundMarker:[NSNull null]];
    
    if (replacingValues != nil && intersectedKeys != nil) {
        return [NSDictionary dictionaryWithObjects:replacingValues forKeys:intersectedKeys];
    }
    
    return @{};
}

- (NSDictionary *)AS_replacOriginKey:(NSArray *)keys withReplacingKeys:(NSArray *)replacingKeys {
    if ([keys count] != [replacingKeys count]) {
        @throw [NSException exceptionWithName:@"Invalid Parameters"
                                       reason:@"Mismatched Input Parameter Count" userInfo:nil];
    }
    
    NSMutableDictionary *replacingDictionary = [self mutableCopy];
    for (NSString *replacedKey in keys) {
        id replacedObject = [self objectForKey:replacedKey];
        if (replacedObject != nil) {
            NSInteger index = [keys indexOfObject:replacedKey];
            [replacingDictionary setObject:replacedObject forKey:replacingKeys[index] ];
        }
    }
    
    return replacingDictionary;
}

- (NSDictionary *)AS_filterOriginKey:(NSArray *)keys withfilterKeys:(NSArray *)filterKeys {
    NSDictionary *replacing = [self AS_replacOriginKey:keys withReplacingKeys:filterKeys];
    return [replacing AS_subDictionaryWithKeys:filterKeys];
}

@end
