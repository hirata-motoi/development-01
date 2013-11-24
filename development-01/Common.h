//
//  Common.h
//  development-01
//
//  Created by Motoi Hirata on 2013/11/24.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Common : NSObject
-(NSInteger*)getImageSequenceId;
-(NSString*)getImagePath:(NSInteger)image_id;
-(void)databaseInitializer;
-(void)kickImageSync;
@end
