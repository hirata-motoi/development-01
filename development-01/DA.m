//
//  DA.m
//  objective-c-test
//
//  Created by Motoi Hirata on 2013/11/24.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "DA.h"
#import "FMDatabase.h"

@implementation DA

+(DA*)da {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *dir = [paths objectAtIndex:0];
    DA *da = [[self alloc] init];
    @autoreleasepool {
        da = [self databaseWithPath:[dir stringByAppendingPathComponent:@"main.db"]];
    }
    return da;
}

@end
