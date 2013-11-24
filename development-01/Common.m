//
//  Common.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/24.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "Common.h"
#import "DA.h"
#import "ImageSync.h"

@implementation Common

-(NSInteger*)getImageSequenceId {
    NSLog(@"getImageSequenceId");
    DA *da = [DA da];
    NSString *stmt_u = @"UPDATE seq_image_id SET id = id + 1";
    NSString *stmt_s = @"SELECT id FROM seq_image_id";
    [da open];
    [da executeUpdate:stmt_u];
    
    FMResultSet *results = [da executeQuery:stmt_s];
    
    NSLog(@"%@", results);
    
    int image_id;
    while ([results next]) {
        image_id = [results intForColumn:@"id"];
    }
    [da close];
    return image_id;
}

-(NSString*)getImagePath:(NSNumber*)image_id {
    return [NSString stringWithFormat:@"%@/%@.jpg", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], image_id];
}

-(void)databaseInitializer {
    
    NSString *image_common = @"CREATE TABLE IF NOT EXISTS image_common(id INTEGER PRIMARY KEY, original_path TEXT, comment TEXT, saved_at INTEGER, created_at INTEGER, updated_at INTEGER)";
    
    NSString *seq_image_id = @"CREATE TABLE IF NOT EXISTS seq_image_id(id INTEGER PRIMARY KEY)";
    NSString *seq_image_id_select = @"SELECT id FROM seq_image_id";
    NSString *seq_image_id_inesrt = @"INSERT OR IGNORE INTO seq_image_id(id) VALUES(?)";
    
    DA *da = [DA da];
    [da open];
    [da executeUpdate:image_common];
    [da executeUpdate:seq_image_id];
    
    FMResultSet *results = [da executeQuery:seq_image_id_select];
    NSLog(@"%@", results);
    if (![results next]) {
        [da executeUpdate:seq_image_id_inesrt, 0];
    }
    [da close];
}

// start to sync image by other processes
-(void)kickImageSync {
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    
    ImageSync * operation1 = [[ImageSync alloc] init];
    [queue addOperation:operation1];
}

@end
