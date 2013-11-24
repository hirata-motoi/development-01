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
    // TODO iOS6と7では名前が違うので対応させる
    //NSString *_AlbumName = @"Saved Photos"; // for iOS7
    NSString *_AlbumName = @"Camera Roll"; // for iOS7
    NSMutableArray *_AlAssetsArr = [NSMutableArray array];
    Common *cm = [[Common alloc] init];
    
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        //ALAssetsLibraryのすべてのアルバムが列挙される
        if (group) {
            //アルバム名が「_AlbumName」と同一だった時の処理
            //NSLog(@"%@", [group valueForProperty:ALAssetsGroupPropertyName]);
            if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
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
                            NSLog(@"result found");
                            NSString *org_path = [results_org_path stringForColumn:@"original_path"];
                            [org_paths setObject:@"1" forKey:org_path];
                        }
                        [da close];
                        //NSLog(@"org_paths : %@", org_paths);
                        
                        for (int i=0; i<[_AlAssetsArr count]; i++) {

                            // 既に保存済の画像の場合はスキップ
                            __weak ALAssetRepresentation *defaultRepresentation = [[_AlAssetsArr objectAtIndex:i] defaultRepresentation];
                            __weak NSURL *image_url = [defaultRepresentation url];
                            NSLog(@"image_path string : %@", [image_url absoluteString]);
                            if ( [org_paths objectForKey:[image_url absoluteString]] ) {
                                NSLog(@"continued");
                                continue;
                            }
                            
                            // 保存用に画像を取得
                            //__weak UIImage *aImage = [UIImage imageWithCGImage:[defaultRepresentation fullScreenImage]];
                            __weak UIImage *aImage = [UIImage imageWithCGImage:[[_AlAssetsArr objectAtIndex:i] thumbnail]];
                            //__weak NSData *data = UIImageJPEGRepresentation(aImage, 0.5);
                            __weak NSData *data = UIImageJPEGRepresentation(aImage, 0.9);
                            
                            //NSLog(@"image resize ended");
                            
                            //NSLog(@"uril instance");
                            __weak NSNumber *image_id = [NSNumber numberWithInteger:[cm getImageSequenceId]];
                            //NSLog(@"image_id:%@", image_id);
                            __weak NSString *path = [cm getImagePath:image_id];
                            NSLog(@"image_path:%@", path);
                            
                            if ([data writeToFile:path atomically:YES]) {
                                // image_commonへ登録
                                //NSLog(@"start DB update");
                                
                                NSString *stmt = @"INSERT INTO image_common (id, original_path, saved_at, created_at, updated_at) VALUES(?,?,?,?,?)";
                                NSDate* date = [NSDate date];
                                
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
                };
                
                //アルバム(group)からALAssetの取得
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                NSLog(@"process ended");
            }
        }
    } failureBlock:nil];
}
@end
