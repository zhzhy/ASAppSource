//
//  AppSourceStore.h
//  AppSource
//
//  Created by DjangoZhang on 15/5/19.
//  Copyright (c) 2015年 DjangoZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSourceStore : NSObject

- (NSString *)storeName;
- (BOOL)isFromAppStore;

@end
