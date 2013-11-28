//
//  AttachedTagsView.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/29.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "AttachedTagsView.h"

@implementation AttachedTagsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//image_idを元に、attachされてるタグを取得し、表示用のviewを作る
//親scrollViewのどこに表示されるのかの情報もここで知っておく
- (AttachedTagsView*)initWithImageId:(NSNumber*)image_id {
    //DBからtag情報を取得
    
    //表示用viewを作る
    UIView *attachedTagsView = [[UIView alloc]init];
    //各々のtagのviewを作る
    
    //表示用viewの位置・大きさを計算
    
    //表示用viewにadd
    
    //表示用のviewを返す
    return attachedTagsView;
}

@end
