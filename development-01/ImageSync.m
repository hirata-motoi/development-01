//
//  ImageSync.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/23.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ImageSync.h"
#import "DA.h"
#import "Common.h"

@implementation ImageSync

-(void)main {
    
    ALAssetsLibrary *_library = [[ALAssetsLibrary alloc] init];
    // TODO iOS6と7以外への対応
    NSDictionary *_AlbumName = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"Saved Photos", @"1", @"Camera Roll", nil];
    NSMutableArray *_AlAssetsArr = [NSMutableArray array];
    Common *cm = [[Common alloc] init];
    
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        //ALAssetsLibraryのすべてのアルバムが列挙される
        if (group) {
            //アルバム名が「_AlbumName」と同一だった時の処理
            //NSLog(@"%@", [group valueForProperty:ALAssetsGroupPropertyName]);
            NSString *group_name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([_AlbumName objectForKey:group_name]) {
                //assetsEnumerationBlock
                ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result) {
                        //asset をNSMutableArraryに格納
                        [_AlAssetsArr addObject:result];
                        
                    }else{
                        //NSMutableArraryに格納後の処理
                        //NSLog(@"%d", [_AlAssetsArr count]);
                        NSInteger assets_count = [_AlAssetsArr count];
                        //NSLog(@"before nslog");
                        //NSLog(@"%d", assets_count);
                        
                        
                        // imageのデータをDBから取得
                        DA *da = [DA da];
                        
                        NSString *stmt_org_path = @"SELECT original_path FROM image_common";
                        [da open];
                        FMResultSet *results_org_path = [da executeQuery:stmt_org_path];
                        NSMutableDictionary *org_paths = [NSMutableDictionary dictionary];
                        while ([results_org_path next]) {
                            NSString *org_path = [results_org_path stringForColumn:@"original_path"];
                            [org_paths setObject:@"1" forKey:org_path];
                        }
                        [da close];
                        //NSLog(@"org_paths : %@", org_paths);
                        
                        for (int i=0; i<[_AlAssetsArr count]; i++) {
                            [self pushProgress:(float)i all:(float)[_AlAssetsArr count]];
                            @autoreleasepool {
                            NSLog(@"i:%d", i);
                                // 既に保存済の画像の場合はスキップ
                                ALAssetRepresentation *defaultRepresentation = [[_AlAssetsArr objectAtIndex:i] defaultRepresentation];
                                ALAsset *thumbnailRepresentation = [_AlAssetsArr objectAtIndex:i];
                                NSURL *image_url = [defaultRepresentation url];
                                //NSLog(@"image_path string : %@", [image_url absoluteString]);
                                if ( [org_paths objectForKey:[image_url absoluteString]] ) {
                                    //NSLog(@"continued");
                                    continue;
                                }
                            
                                // 保存用に画像を取得
                                CGImageRef aImageRef = [defaultRepresentation fullScreenImage];
                                UIImage *aImage = [UIImage imageWithCGImage:aImageRef];
                            
                                CGImageRef tImageRef = [thumbnailRepresentation thumbnail];
                                UIImage *tImage = [UIImage imageWithCGImage:tImageRef];
                            
                                NSData *adata = UIImageJPEGRepresentation(aImage, 1);
                                NSData *tdata = UIImageJPEGRepresentation(tImage, 1);
                            
                                //NSLog(@"uril instance");
                                NSNumber *image_id = [NSNumber numberWithInteger:[cm getImageSequenceId]];
                                //NSLog(@"image_id:%@", image_id);
                                NSString *apath = [cm getImagePath:image_id];
                                NSString *tpath = [cm getImagePathThumbnail:image_id];
                                //NSLog(@"image_path:%@", tpath);
                            
                                if (
                                    [adata writeToFile:apath atomically:YES] &&
                                    [tdata writeToFile:tpath atomically:YES]
                                ) {
                                    // image_commonへ登録
                                    //NSLog(@"start DB update");
                                
                                    NSString *stmt = @"INSERT INTO image_common (id, original_path, saved_at, created_at, updated_at) VALUES(?,?,?,?,?)";
                                    NSDate*date = [NSDate date];
                                
                                    //NSLog(@"image_url : %@", image_url);
                                    //NSLog(@"%@", date);
                                
                                    [da open];
                                    [da executeUpdate:stmt, image_id
                                        , image_url, date, date, date];
                                    [da close];
                                
                                } else {
                                    // TODO 失敗したよもっかいやってね というダイアログ出す
                                }
                            }
                        }
                    }
                };
                
                //アルバム(group)からALAssetの取得
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                NSLog(@"process ended");
            }
        }
    } failureBlock:nil];
}

- (void)pushProgress:(float)i all:(float)all
{
    float progress = (float)((i + 1)/ all);
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", progress], @"progress", nil];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"barProgress"
                      object:self
                        userInfo:info];
}

@end
