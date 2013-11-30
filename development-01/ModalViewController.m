//
//  ModalViewController.m
//  development-01
//
//  Created by Motoi Hirata on 2013/11/28.
//  Copyright (c) 2013年 Motoi Hirata. All rights reserved.
//

#import "ModalViewController.h"
#import "Common.h"
#import "HorizontalScrollView.h"
#import "SettingView.h"
#import "DA.h"
#import "FMDatabase.h"
#import "TagScrollView.h"
@interface ModalViewController ()


@end

@implementation ModalViewController
@synthesize addedImagesWithIndex;
@synthesize imageIdIndexMap;
@synthesize addedTagLabelsDictionary;
@synthesize attachedTagIdsArrayByImageId;
@synthesize attachedTagLabelsForImageId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    self.addedImagesWithIndex = [[NSMutableDictionary alloc]init];
    self.imageIdIndexMap      = [[NSMutableDictionary alloc]init];
    self.addedTagLabelsDictionary = [[NSMutableDictionary alloc]init];
    self.attachedTagIdsArrayByImageId = [[NSMutableDictionary alloc]init];
    self.attachedTagLabelsForImageId = [[NSMutableDictionary alloc]init];
    _showSettingView = NO; // default非表示
    
    //imageIdIndexMapのセット
    for (int i = 0; i < imageIds.count; i++) {
        NSNumber *image_id = [imageIds objectAtIndex:i];
        NSNumber *i_number = [NSNumber numberWithInt:i];
        [imageIdIndexMap setObject:i_number forKey:[image_id stringValue]];
    }
    
	// Do any additional setup after loading the view.
    UIBarButtonItem *bbDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
    
    self.navigationItem.rightBarButtonItem = bbDone;
    
    //scrollviewのデリゲート設定
    HorizontalScrollView *scrollView = [[HorizontalScrollView alloc]init];
    scrollView.delegate = self;
    //scrollviewの各種設定
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.7 alpha:1.0];
    scrollView.userInteractionEnabled = YES;
    
    //1ページのフレームサイズ
    scrollView.frame = self.view.bounds;
    CGRect aFrame = scrollView.frame;
    //スクロールするコンテンツの縦横サイズ
    scrollView.contentSize = CGSizeMake(aFrame.size.width * imageIds.count, aFrame.size.height);
    CGPoint pnt = CGPointMake(aFrame.size.width * [imageIndex intValue], 0);
    [scrollView setContentOffset:pnt animated:YES];
    
    scrollViewObject = scrollView;

    // タップされた画像とその前後だけ出す
    NSMutableArray *index_list = [[NSMutableArray alloc]init];
    [index_list addObject:imageIndex];
    if ( [imageIndex intValue] > 0 ) {
        int beforeIndex = [imageIndex intValue] - 1;
        NSNumber *beforeIndexNumber = [NSNumber numberWithInt:beforeIndex];
        [index_list addObject:beforeIndexNumber];
    }
    if ( [imageIndex intValue] < imageIds.count - 1) {
        int afterIndex = [imageIndex intValue] + 1;
        NSNumber *afterIndexNumber = [NSNumber numberWithInt:afterIndex];
        [index_list addObject:afterIndexNumber];
    }
    [self addImagesToScrollViewWithIndexes:index_list];

    //タップした時の処理を定義

    //settingviewをゲット
    //settingViewをaddSubviewする
    //settingViewをインスタンス変数にadd
    //タップ時の処理をここで定義
    
    //image_idからattachedTagsをゲット
    //attachedTagsをaddSubviewする
    //attachedTagsをインスタンス変数にadd
    //タップ時の処理をここで定義
    [self.view addSubview:scrollView];
}

- (void)closeView{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageInfo:(NSNumber*)image_id withIndex:(NSNumber*)index withImageIds:(NSArray*)image_ids {
    imageId    = image_id;
    imageIndex = index;
    imageIds   = image_ids;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
         
    if (scrollViewObject != nil) {
        //現在のページ番号を調べる
        CGFloat pageWidth = scrollViewObject.frame.size.width;
        int pageNo = floor((scrollViewObject.contentOffset.x - pageWidth/2)/pageWidth);
        
        if (pageNo < 0 || pageNo > imageIds.count - 1) {
            return;
        }
    
        //前後の写真を読み込む
        int beforeNo = pageNo - 1;
        int afterNo  = pageNo + 1;
        //NSArray * index_list = [[NSArray alloc]initWithObjects:beforeNo, afterNo, nil];
        NSMutableArray *index_list = [[NSMutableArray alloc] init];
        if (beforeNo >= 0) {
            NSNumber *beforeNoNumber = [NSNumber numberWithInt:beforeNo];
            [index_list addObject:beforeNoNumber];
        }
        if (afterNo <= imageIds.count) {
            NSNumber *afterNoNumber = [NSNumber numberWithInt:afterNo];
            [index_list addObject:afterNoNumber];
        }
        
        //imageIdの変更
        imageId = [imageIds objectAtIndex:pageNo];

        [self addImagesToScrollViewWithIndexes:index_list];
    }
}

- (int)getCurrentImageIndex {
    
    if (scrollViewObject != nil) {
        //現在のページ番号を調べる
        CGFloat pageWidth = scrollViewObject.frame.size.width;
        int pageNo = floor(scrollViewObject.contentOffset.x/pageWidth);
        
        if (pageNo < 0 || pageNo > imageIds.count - 1) {
            return -1;
        }
        return pageNo;
    }
    return -1;
}

- (void)addImagesToScrollViewWithIndexes:(NSMutableArray*)index_list {

    for (NSNumber *index in index_list) {
        if ( [addedImagesWithIndex objectForKey:[index stringValue]] != nil) {
            //すでに追加済の画像
            continue;
        }
        
        Common *cm = [[Common alloc]init];
        
        NSNumber *image_id = [imageIds objectAtIndex:[index intValue]];
        NSString *image_path = [cm getImagePathThumbnail:image_id];
        UIImage *image = [UIImage imageWithContentsOfFile:image_path];
        
        
        // いい感じのサイズに補正
        int image_width   = image.size.width;
        int image_height  = image.size.height;
        int screen_width  = self.view.bounds.size.width;
        int screen_height = self.view.bounds.size.height;
        
        float width_rate  = (float)image_width / screen_width;
        float height_rate = (float)image_height / screen_height;
        float rate        = (width_rate > height_rate) ? width_rate : height_rate;
        
        int arranged_width = floor(image_width / rate);
        int arranged_height = floor(image_height / rate);

        UIView * view = [[UIView alloc]init];
        CGRect vFrame = self.view.bounds;
        vFrame.origin.x = scrollViewObject.frame.size.width * [index intValue];
        [view setFrame:vFrame];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:[[UIScreen mainScreen]applicationFrame]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:image];
        imageView.tag = [image_id intValue];
        CGRect imageFrame = imageView.frame;

        imageFrame.size.width = arranged_width;
        imageFrame.size.height = arranged_height;
        
        imageFrame.origin.y = (vFrame.size.height - imageFrame.size.height) / 2;
        [imageView setFrame:imageFrame];
        [view addSubview:imageView];
        NSLog(@"tagging before");
        view.tag = [image_id intValue];
        NSLog(@"tagging after");

        [scrollViewObject addSubview:view];

        [addedImagesWithIndex setValue:imageView forKeyPath:[index stringValue]];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched!!!!");
    
    UITouch *touch = [touches anyObject];
    int image_id = touch.view.tag;
    NSNumber * image_id_number = [NSNumber numberWithInt:image_id];
    id tt = touch.view;
    NSLog(@"touchesEnded tt : %@", tt);

    
    if (settingViewObject != nil ) {
        _showSettingView = !_showSettingView;
        settingViewObject.hidden = _showSettingView;
        //labelの表示/非表示きりかえ
        [self switchTagLabels:image_id_number];

    } else {
        _showSettingView = !_showSettingView;
        CGRect rect = self.view.bounds;
        rect.origin.x = 0;
        rect.origin.y = rect.size.height - 50;
        rect.size.height = 50;
        
        SettingView *settingView = [[SettingView alloc]initWithFrame:rect];
        settingView.backgroundColor = [UIColor blueColor];
        
        TagScrollView *tagScrollView = [[TagScrollView alloc]init];
        tagScrollView.delegate = self;
        //scrollviewの各種設定
        tagScrollView.scrollEnabled = YES;
        tagScrollView.pagingEnabled = YES;
        tagScrollView.showsHorizontalScrollIndicator = NO;
        tagScrollView.showsVerticalScrollIndicator = NO;
        tagScrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.7 alpha:1.0];
        tagScrollView.userInteractionEnabled = YES;
        
        //tagの取得
        NSMutableArray * tags = [[NSMutableArray alloc]init];
        NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
        NSString *stmt = @"SELECT id, tag_name FROM tags";
        DA *da = [DA da];
        [da open];
        FMResultSet *results = [da executeQuery:stmt];
        while ([results next]) {
            NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
            NSString * tag_name = [results stringForColumn:@"tag_name"];
            NSDictionary *unit = @{
                @"id":tag_id,
                @"tag_name": tag_name,
            };
            [tags addObject:unit];
            [tags_dictionary setObject:tag_name forKey:[tag_id stringValue]];
        }
        [da close];
        
        //1ページのフレームサイズ
        int scrollViewWidth = ((50 + 10) * tags.count + 10) < self.view.bounds.size.width ? self.view.bounds.size.width : ((50 + 10) * tags.count + 10);
        int scrollViewHeight = 40;
        int scrollViewOriginX = 0;
        int scrollViewOriginY = 5;
        
        CGRect screenRect = self.view.bounds;
        tagScrollView.frame = CGRectMake(0, 15, screenRect.size.width, 30);
        
        //スクロールするコンテンツの縦横サイズ
        tagScrollView.contentSize = CGSizeMake(scrollViewWidth, scrollViewHeight);
        
        //ラベルを作る
        for (int i = 0; i<tags.count; i++) {
            NSDictionary * unit = [tags objectAtIndex:i];
            NSNumber * tag_id   = [unit objectForKey:@"id"];
            NSString * tag_name = [unit objectForKey:@"tag_name"];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
            label.text = tag_name;
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor whiteColor];
            label.userInteractionEnabled = YES;
            label.textAlignment = UITextAlignmentCenter;
            label.tag = [tag_id integerValue];
            
            UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake((10 + (50 + 10)* i), 0, 50, 40)];
            label.backgroundColor = [UIColor clearColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
            gradient.frame = CGRectMake(0, 0, 50, 40);
            gradient.endPoint=CGPointMake(1.0, 0.0);
            [labelBackground.layer addSublayer:gradient];
            [labelBackground addSubview:label];
            label.text = tag_name;
            
            UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
            label.userInteractionEnabled = YES;
            [label addGestureRecognizer:recognizer];

            [tagScrollView addSubview:labelBackground];
        }
        
        
        // ラベルの位置を調整
        [self setTagInfoForImageId:image_id_number];
        NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id_number stringValue]];
        NSMutableArray * tagIdsForImageId = [attachedTagIdsArrayByImageId objectForKey:[image_id_number stringValue]];
        [self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
        
        NSLog(@"arranged tags : %@", tagsForImageId);
        NSLog(@"arranged tag array : %@", tagIdsForImageId);
        
        //attach済ラベルを表示
        NSNumber * image_index = [NSNumber numberWithInteger:[imageIds indexOfObject:[NSNumber numberWithInt:image_id]]];
        
        for (int i = 0; i<tagIdsForImageId.count; i++) {
            NSNumber * tag_id = [tagIdsForImageId objectAtIndex:i];
            NSString * tag_name = [tags_dictionary objectForKey:[tag_id stringValue]];
            UIView * labelBackgroundView = [self createAttachedTagLabelView:tag_id withTagName:tag_name];
            
            [tagsForImageId setObject:labelBackgroundView forKey:[tag_id stringValue]];
        }

        // locationの設定
        [self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
        
        // attach対象のimageView
        UIImageView * targetImageView = [addedImagesWithIndex objectForKey:[image_index stringValue]];

        
        for (NSNumber * tag_id_num in tagIdsForImageId) {
            NSString * tag_id_str = [tag_id_num stringValue];
            UIView * labelView = [tagsForImageId objectForKey:tag_id_str];
            [targetImageView addSubview:labelView];
        }
        NSLog(@"imageView add finish");
        [settingView addSubview:tagScrollView];
        [self.view addSubview:settingView];
        settingViewObject = settingView;
    }
}

- (void)labelTapped2:(UITapGestureRecognizer*)recognizer {
    NSLog(@"tapped label!!!!!!!!!!!");
    

    //タップされたタグのid
    NSInteger tag_id = recognizer.view.tag;
    NSLog(@"tag_id : %d", (long)tag_id);
    NSNumber * tag_id_number = [NSNumber numberWithInteger:tag_id];
    NSNumber * image_id = [NSNumber numberWithInt:[self getCurrentImageIndex]];
    
    DA * da = [DA da];
    [da open];
    NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
    NSString *stmt = @"SELECT id, tag_name FROM tags";
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSString * tag_name = [results stringForColumn:@"tag_name"];
        NSDictionary *unit = @{
                               @"id":tag_id, @"tag_name": tag_name,
                               };
        [tags_dictionary setObject:unit forKey:[tag_id stringValue]];
    }
    [da close];
    
    NSLog(@"addedTagLabels : %@", addedTagLabelsDictionary);
    NSMutableDictionary * tagsForImageId = [addedTagLabelsDictionary objectForKey:[image_id stringValue]];
    if (tagsForImageId && [tagsForImageId objectForKey:[tag_id_number stringValue]]) {
        NSLog(@" already tagged");
        //DB更新
        //object消す
        //座標を整える
        //再度表示
    } else {
        //tagを作る
        NSString *tag_name = [[tags_dictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name" ];
        
        //幅 : 25
        //高さ : 15
        //余白 : 5
        int extra = 5;
        int labelHeight = 15;
        int labelWidth  = 25;
        int labelOriginX = self.view.bounds.size.width - labelWidth - extra;
        

        UILabel *label = [[UILabel alloc]init];
        label.text = tag_name;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = YES;
        label.textAlignment = UITextAlignmentCenter;
        label.tag = tag_id;


        
        NSArray * attachedTagIds = [tagsForImageId allKeys];
        int initialOriginY = extra + (labelHeight + extra) * attachedTagIds.count;
        
        UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake(labelOriginX, initialOriginY, labelWidth, labelHeight)];
        label.frame = CGRectMake(0, 0, labelWidth, labelHeight);
        label.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = label.frame;
        [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
        gradient.endPoint=CGPointMake(1.0, 0.0);
        [labelBackground.layer addSublayer:gradient];
        [labelBackground addSubview:label];
        label.text = tag_name;

        
        NSString *image_index = [[NSNumber numberWithInt:[self getCurrentImageIndex]] stringValue];
        NSLog(@"image_index : %@    getCurrentImageIndex:%d", image_index, [self getCurrentImageIndex]);
        id image_object = [addedImagesWithIndex objectForKey:image_index];
        [image_object addSubview:labelBackground];
        
        
        // ハッシュでlabelのポインタを管理
        [tagsForImageId setObject:label forKey:[tag_id_number stringValue]];
        
        // 配列でlabelの並び順を管理
        NSMutableArray *tagsArrayForImageId = [attachedTagIdsArrayByImageId objectForKey:[image_id stringValue]];
        [tagsArrayForImageId addObject:tag_id_number];
        
        
        // labelの位置を整えつつ表示する
        for (int i = 0; i<tagsArrayForImageId.count; i++) {
            
            NSNumber * tag_id_number = [tagsArrayForImageId objectAtIndex:i];
            NSString *tag_name = [[tags_dictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name"];
            UILabel * obj = [[UILabel alloc]init];
            obj.text = tag_name;
            //obj.tag = [key intValue];
            obj.backgroundColor  = [UIColor blueColor];
            
            int labelOriginY = extra + (labelHeight + extra) * i;
            obj.frame = CGRectMake(labelOriginX, labelOriginY, labelWidth, labelHeight);
            NSLog(@"label  tag_name:%@ x:%d y:%d w:%d h:%d", tag_name, labelOriginX, labelOriginY, labelWidth, labelHeight);
            
            [image_object addSubview:obj];
            //NSLog(@"image_object added tags : %@", image_object);
        }
        
        //DB更新
        [da open];
        NSString *stmt_tag_save = @"INSERT INTO tag_map (tag_id, image_id, created_at) VALUES(?,?,?)";
        NSNumber *tag_id_number = [NSNumber numberWithInt:tag_id];
        
        NSDate* date = [NSDate date];
        [da executeUpdate:stmt_tag_save, tag_id_number, imageId, date];
        [da close];
    }

}


- (void)labelTapped:(UITapGestureRecognizer*)recognizer {
    // tag_id
    int tag_id = recognizer.view.tag;
    NSNumber * tag_id_number = [NSNumber numberWithInt:tag_id];
    
    // image_id
    NSNumber * image_index = [NSNumber numberWithInt:[self getCurrentImageIndex]];
    NSNumber * image_id = [imageIds objectAtIndex:[image_index integerValue]];
    
    // 既存のタグ情報
    NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id stringValue]];
    if (!tagsForImageId) {
        tagsForImageId = [[NSMutableDictionary alloc]init];
        [attachedTagLabelsForImageId setObject:tagsForImageId forKey:[image_id stringValue]];
    }
    NSMutableArray * tagIdsForImageId = [attachedTagIdsArrayByImageId objectForKey:[image_id stringValue]];
    if (!tagIdsForImageId) {
        tagIdsForImageId = [[NSMutableArray alloc]init];
        [attachedTagIdsArrayByImageId setObject:tagIdsForImageId forKey:[image_id stringValue]];
    }
    
    //全tagの情報
    NSMutableDictionary * tagsDictionary = [self getTagsInfo];
    
    // 既に該当tagがついていた場合は消去
    if (tagsForImageId && [tagsForImageId objectForKey:[tag_id_number stringValue]]) {
        NSLog(@"delete tag");
        //タグの情報を取得
        id deleteTargetObject = [tagsForImageId objectForKey:[tag_id_number stringValue]];
        
        //tagsForImageIdから消す
        [tagsForImageId removeObjectForKey:[tag_id_number stringValue]];
        
        //tagIdsForImageIdから消す
        [tagIdsForImageId removeObjectAtIndex:[image_index integerValue]];
        
        //viewから消す
        [deleteTargetObject removeFromParentViewController];

        // ラベルの位置を調整
        [self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
        
        return;
    }
    
    //labelを作成
    NSString *tag_name = [[tagsDictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name" ];
    UIView * labelBackgroundView = [self createAttachedTagLabelView:tag_id_number withTagName:tag_name];

    // 既存タグ情報に追加
    [tagsForImageId setObject:labelBackgroundView forKey:[tag_id_number stringValue]];
    [tagIdsForImageId addObject:tag_id_number];
    
    // ラベルの位置を調整
    [self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
    
    //新規のラベルを表示
    UIImageView * targetImageView = [addedImagesWithIndex objectForKey:[image_index stringValue]];
    [targetImageView addSubview:labelBackgroundView];
    
    //DB更新
    DA * da = [DA da];
    [da open];
    NSString *stmt_tag_save = @"INSERT INTO tag_map (tag_id, image_id, created_at) VALUES(?,?,?)";
    NSDate* date = [NSDate date];
    [da executeUpdate:stmt_tag_save, tag_id_number, image_id, date];
    [da close];
}



//attachされているタグをfor文で回してframe.originを適切に設定
- (void) arrangeTagLabelLocation:(NSMutableDictionary *)tagsForImageId withIndexes:(NSMutableArray *)tagIdsForIamgeId {
    int extra = 5;
    int labelHeight = 15;
    int labelWidth = 25;
    int labelOriginX = self.view.bounds.size.width - labelWidth - extra;
    int labelOriginInitialY = 5;
    for (int i = 0; i < tagIdsForIamgeId.count; i++) {
        NSNumber * index_number = [NSNumber numberWithInt:i];

        int labelOriginY = labelOriginInitialY + labelHeight * i;
        
        NSNumber * tag_id_number = [tagIdsForIamgeId objectAtIndex:i];
        UIView * labelBackground = [tagsForImageId objectForKey:[tag_id_number stringValue]];
        
        CGRect rect = labelBackground.frame;
        rect.origin.x = labelOriginX;
        rect.origin.y = labelOriginY;
        
        labelBackground.frame = rect;
    }
}

-(NSMutableDictionary*) getTagsInfo {
    DA * da = [DA da];
    [da open];
    NSMutableDictionary *tags_dictionary = [[NSMutableDictionary alloc]init];
    NSString *stmt = @"SELECT id, tag_name FROM tags";
    [da open];
    FMResultSet *results = [da executeQuery:stmt];
    while ([results next]) {
        NSNumber * tag_id   = [NSNumber numberWithInt:[results intForColumn:@"id"]];
        NSString * tag_name = [results stringForColumn:@"tag_name"];
        NSDictionary *unit = @{
                               @"id":tag_id, @"tag_name": tag_name,
                               };
        [tags_dictionary setObject:unit forKey:[tag_id stringValue]];
    }
    [da close];
    return tags_dictionary;
}

-(UIView *)createAttachedTagLabelView:(NSNumber*)tag_id_number withTagName:(NSString*)tag_name {
    //幅 : 25
    //高さ : 15
    //余白 : 5
    int extra = 5;
    int labelHeight = 15;
    int labelWidth  = 25;
    int labelOriginX = self.view.bounds.size.width - labelWidth - extra;
    
    int tag_id = [tag_id_number intValue];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = tag_name;
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    label.textAlignment = UITextAlignmentCenter;
    label.tag = tag_id;
    label.frame = CGRectMake(0, 0, labelWidth, labelHeight);
    label.backgroundColor = [UIColor clearColor];
    label.text = tag_name;
    label.backgroundColor = [UIColor blueColor];
    
    UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    labelBackground.backgroundColor = [UIColor blackColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = label.frame;
    [gradient setColors:[NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor grayColor].CGColor),nil]];
    gradient.endPoint=CGPointMake(1.0, 0.0);
    [labelBackground.layer addSublayer:gradient];
    [labelBackground addSubview:label];
    
    return labelBackground;
}

-(void)setTagInfoForImageId:(NSNumber*)image_id {
    NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id stringValue]];
    if (!tagsForImageId) {
        tagsForImageId = [[NSMutableDictionary alloc]init];
        [attachedTagLabelsForImageId setObject:tagsForImageId forKey:[image_id stringValue]];
    }
    NSMutableArray * tagIdsForImageId = [attachedTagIdsArrayByImageId objectForKey:[image_id stringValue]];
    if (!tagIdsForImageId) {
        tagIdsForImageId = [[NSMutableArray alloc]init];
        [attachedTagIdsArrayByImageId setObject:tagIdsForImageId forKey:[image_id stringValue]];
    }
    
    //tag_mapをselect
    DA * da = [DA da];
    NSString * stmt = @"SELECT tag_id FROM tag_map where image_id = ?";
    [da open];
    NSLog(@"select image_id : %@", image_id);
    FMResultSet * results = [da executeQuery:stmt, image_id];
    while ([results next]) {
        int tag_id_int = [results intForColumn:@"tag_id"];
        NSNumber * tag_id_number = [NSNumber numberWithInt:tag_id_int];
        [tagIdsForImageId addObject:tag_id_number];
    }
    NSLog(@"tagIdsForImageId : %@", tagIdsForImageId);
    [da close];
}

- (void)switchTagLabels:(NSNumber*)image_id {
    NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id stringValue]];
    for (UIView * tagView in [tagsForImageId allValues]) {
        tagView.hidden = _showSettingView;
    }
}
@end
