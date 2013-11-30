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
#import "ImageController.h"

@implementation Common

-(NSInteger*)getImageSequenceId {
    DA *da = [DA da];
    NSString *stmt_u = @"UPDATE seq_image_id SET id = id + 1";
    NSString *stmt_s = @"SELECT id FROM seq_image_id";
    [da open];
    [da executeUpdate:stmt_u];
    
    FMResultSet *results = [da executeQuery:stmt_s];
    
    int image_id;
    while ([results next]) {
        image_id = [results intForColumn:@"id"];
    }
    [da close];
    return image_id;
}

-(NSString*)getImagePath:(NSNumber*)image_id {
    return [NSString stringWithFormat:@"%@/%@/%@.jpg", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"fullscreen", image_id];
}

-(NSString*)getImagePathThumbnail:(NSNumber*)image_id {
    return [NSString stringWithFormat:@"%@/%@/%@.jpg", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"thumbnail", image_id];
}

-(void)databaseInitializer {
    
    NSString *image_common = @"CREATE TABLE IF NOT EXISTS image_common(id INTEGER PRIMARY KEY, original_path TEXT, comment TEXT, saved_at INTEGER, created_at INTEGER, updated_at INTEGER)";
    NSString *seq_image_id = @"CREATE TABLE IF NOT EXISTS seq_image_id(id INTEGER PRIMARY KEY)";
    NSString *tags = @"CREATE TABLE IF NOT EXISTS tags(id INTEGER PRIMARY KEY, tag_name TEXT UNIQUE)";
    NSString *tag_map = @"CREATE TABLE IF NOT EXISTS tag_map(tag_id INTEGER, image_id INTEGER, created_at INTEGER)";
//    NSString *create_i1_to_tag_map = @"CREATE INDEX i1 ON tag_map(tag_id)";
//    NSString *create_i2_to_tag_map = @"CREATE INDEX i2 ON tag_map(image_id)";
    NSString *seq_image_id_select = @"SELECT id FROM seq_image_id";
    NSString *seq_image_id_inesrt = @"INSERT OR IGNORE INTO seq_image_id(id) VALUES(?)";
    NSString *insert_map_def_data = @"INSERT OR IGNORE INTO tags(id, tag_name) values(?, ?)";
    
    DA *da = [DA da];
    [da open];
    [da executeUpdate:image_common];
    [da executeUpdate:seq_image_id];
    [da executeUpdate:tags];
    [da executeUpdate:tag_map];
//    [da executeUpdate:create_i1_to_tag_map];
//    [da executeUpdate:create_i2_to_tag_map];
    // Do NOT change favorit id (id = 1, favorite)!!!!!!!
    [da executeUpdate:insert_map_def_data, [NSNumber numberWithInt:1], [NSString stringWithFormat:@"favorite"]];
    [da executeUpdate:insert_map_def_data, [NSNumber numberWithInt:2], [NSString stringWithFormat:@"share"]];
    [da executeUpdate:insert_map_def_data, [NSNumber numberWithInt:3], [NSString stringWithFormat:@"smile"]];
    [da executeUpdate:insert_map_def_data, [NSNumber numberWithInt:4], [NSString stringWithFormat:@"cry"]];
    [da executeUpdate:insert_map_def_data, [NSNumber numberWithInt:5], [NSString stringWithFormat:@"angry"]];
    
    FMResultSet *results = [da executeQuery:seq_image_id_select];
    if (![results next]) {
        [da executeUpdate:seq_image_id_inesrt, 0];
    }
    [da close];
}

- (void) filesystemInitializer {
    NSString *fullscreenDirPath = [NSString stringWithFormat:@"%@/%@/", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"fullscreen"];
    NSString *thumbnailDirPath = [NSString stringWithFormat:@"%@/%@/", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"thumbnail"];
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL resultFullscreen = [fileManager createDirectoryAtPath:fullscreenDirPath
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
    BOOL resultThumbnail = [fileManager createDirectoryAtPath:thumbnailDirPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error];
}

// start to sync image by other processes
-(void)kickImageSync {
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    
    ImageSync * operation1 = [[ImageSync alloc] init];
    [queue addOperation:operation1];
}


- (void)closeImageView:(id*)sender {
    [imageViewControllerObject dismissViewControllerAnimated:YES completion:^{}];
}

// 表示用に画面のサイズに合わせて画像をリサイズ
-(CGRect *)imageFrameInfo:(CGSize)imageSize viewSize:(CGRect*)viewRect{
    
    NSInteger imageWidth  = imageSize.width;
    NSInteger imageHeight = imageSize.height;
    
    
    CGFloat widthRatio  = imageWidth  / viewRect->size.width;
    CGFloat heightRatio = imageHeight / viewRect->size.height;
    
    CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
    
    if (ratio >= 1.0) {
        ratio = 1.0;
    }
    
    NSInteger width  = viewRect->size.width / ratio;
    NSInteger height = imageHeight / ratio;
    
    NSInteger locationY = (viewRect->size.height - height) / 2;
    CGRect rect = CGRectMake(0, locationY, width, height);
    return &rect;
}

@end
