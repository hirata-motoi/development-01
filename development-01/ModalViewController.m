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
#import "CommentEditViewController.h"
@interface ModalViewController ()


@end

@implementation ModalViewController
@synthesize addedImagesWithIndex;
@synthesize imageIdIndexMap;
@synthesize attachedTagIdsArrayByImageId;
@synthesize attachedTagLabelsForImageId;
@synthesize existTagsDictionary;
@synthesize existTagsArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.addedImagesWithIndex = [[NSMutableDictionary alloc]init];
    self.imageIdIndexMap      = [[NSMutableDictionary alloc]init];
    self.attachedTagLabelsForImageId = [[NSMutableDictionary alloc]init];
    self.attachedTagIdsArrayByImageId = [[NSMutableDictionary alloc]init];
    _showSettingView = YES; // default表示
    self.existTagsDictionary = [[NSMutableDictionary alloc]init];
    self.existTagsArray = [[NSMutableArray alloc]init];
    
    //imageIdIndexMapのセット
    for (int i = 0; i < imageIds.count; i++) {
        NSNumber *image_id = [imageIds objectAtIndex:i];
        NSNumber *i_number = [NSNumber numberWithInt:i];
        [imageIdIndexMap setObject:i_number forKey:[image_id stringValue]];
    }
    
    // 全tagの情報を取得してセット
    NSString *stmt = @"SELECT id, tag_name FROM tags"; // only normal tag
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
        if ([tag_id intValue] < 1000) {
            [existTagsArray addObject:unit];
        }
        [existTagsDictionary setObject:tag_name forKey:[tag_id stringValue]];
    }
    [da close];
	// Do any additional setup after loading the view.
//    UIBarButtonItem *bbDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
//    
//    self.navigationItem.rightBarButtonItem = bbDone;
//    
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
    
    
    // attach済tagのlabelを表示
    [self showAttachedTagLabels:imageId];

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
    
    // settingViewを表示
    [self createSettingView:imageId];
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
        int pageNo = floor((scrollViewObject.contentOffset.x + pageWidth/2)/pageWidth);
        
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
        if (afterNo < imageIds.count) {
            NSNumber *afterNoNumber = [NSNumber numberWithInt:afterNo];
            [index_list addObject:afterNoNumber];
        }

        NSNumber * image_id_number = [imageIds objectAtIndex:pageNo];
        
        [self addImagesToScrollViewWithIndexes:index_list];

        //commentViewのcommentを切り替え
        [self replaceComment:image_id_number];
        
        //attach済のtag labelを表示
        [self switchTagLabels:image_id_number];
        
        //非表示のimageのメモリ解放
        [self releaseRedundantImage:index_list withSelfIndex:[NSNumber numberWithInt:pageNo]];
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
        NSString *image_path = [cm getImagePath:image_id];
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
        view.tag = [image_id intValue];

        [scrollViewObject addSubview:view];

        [addedImagesWithIndex setValue:imageView forKeyPath:[index stringValue]];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    int image_id = touch.view.tag;
    NSNumber * image_id_number = [NSNumber numberWithInt:image_id];
    
    if (settingViewObject != nil ) {
        _showSettingView = !_showSettingView;
        settingViewObject.hidden = !_showSettingView;
        self.navigationController.toolbarHidden = !_showSettingView;

        //labelの表示/非表示きりかえ
        [self switchTagLabels:image_id_number];
    } else {
        // viewDidLoadでsettingViewを作るのでこのif文に入ることはないはず
        [self createSettingView:image_id_number];
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
    NSLog(@"tagIdssForImageId2 : %@", tagIdsForImageId);
    NSLog(@"attachedTagIdsArrayByImageId : %@   image_id:%@", attachedTagIdsArrayByImageId, image_id);
    if (!tagIdsForImageId) {
        tagIdsForImageId = [[NSMutableArray alloc]init];
        [attachedTagIdsArrayByImageId setObject:tagIdsForImageId forKey:[image_id stringValue]];
    }
    NSLog(@"tagIdssForImageId : %@", tagIdsForImageId);
    
    //全tagの情報
    NSMutableDictionary * tagsDictionary = [self getTagsInfo];
    
    // 既に該当tagがついていた場合は消去
    if (tagsForImageId && [tagsForImageId objectForKey:[tag_id_number stringValue]]) {
        //タグの情報を取得
        id deleteTargetObject = [tagsForImageId objectForKey:[tag_id_number stringValue]];
        
        //viewから消す
        [deleteTargetObject removeFromSuperview];
        
        //tagsForImageIdから消す
        [tagsForImageId removeObjectForKey:[tag_id_number stringValue]];
        
        //tagIdsForImageIdから消す
        for (int i = tagIdsForImageId.count - 1; i >= 0; i--) {
            NSNumber * tid = [tagIdsForImageId objectAtIndex:i];
            if (tid == tag_id_number) {
                [tagIdsForImageId removeObject:tid];
            }
        }

        // ラベルの位置を調整
        [self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
        
        //DB更新
        DA * da = [DA da];
        [da open];
        NSString * stmt_delete = @"DELETE FROM tag_map where tag_id = ? AND image_id = ?";
        [da executeUpdate:stmt_delete, tag_id_number, image_id];
        [da close];
        
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
        NSLog(@"origin.x:%d origin.y:%d", rect.origin.x, rect.origin.y);
        
        labelBackground.frame = rect;
    }
}

// normal/special含め全tagの情報を持つ。tag_idを元にtag_nameを引くためにしか使わないこと！！
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
    
    UIView * labelBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    labelBackground.backgroundColor = [UIColor clearColor];
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
        //tag_mapをselect
        DA * da = [DA da];
        NSString * stmt = @"SELECT tag_id FROM tag_map WHERE image_id = ? AND tag_id < 1000";
        [da open];
        FMResultSet * results = [da executeQuery:stmt, image_id];
        while ([results next]) {
            int tag_id_int = [results intForColumn:@"tag_id"];
            NSNumber * tag_id_number = [NSNumber numberWithInt:tag_id_int];
            [tagIdsForImageId addObject:tag_id_number];
        }
        [da close];
    }
}

- (void)switchTagLabels:(NSNumber*)image_id {
    NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id stringValue]];
    if (!tagsForImageId) {
        [self showAttachedTagLabels:image_id];
    }
    else {
        for (UIView * tagView in [tagsForImageId allValues]) {
            tagView.hidden = !_showSettingView;
        }
    }
}

- (void) showAttachedTagLabels:(NSNumber*)image_id_number {
    
    // attach済tag labelを表示
    [self setTagInfoForImageId:image_id_number];
    NSMutableDictionary * tagsForImageId = [attachedTagLabelsForImageId objectForKey:[image_id_number stringValue]];
    NSMutableArray * tagIdsForImageId = [attachedTagIdsArrayByImageId objectForKey:[image_id_number stringValue]];
    NSNumber * image_index = [NSNumber numberWithInteger:[imageIds indexOfObject:image_id_number]];
    
    for (int i = 0; i<tagIdsForImageId.count; i++) {
        NSNumber * tag_id = [tagIdsForImageId objectAtIndex:i];
        NSString * tag_name = [existTagsDictionary objectForKey:[tag_id stringValue]];
        UIView * labelBackgroundView = [self createAttachedTagLabelView:tag_id withTagName:tag_name];
        labelBackgroundView.hidden = !_showSettingView;
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
    
    // share tagのラベルを表示
    // TODO magic number
    NSNumber * tag_id_number_share = [NSNumber numberWithInt:1000];
    DA * da = [DA da];
    [da open];
    NSString * stmt_share_tag = @"SELECT 1 FROM tag_map WHERE image_id = ? AND tag_id = 1000";
    FMResultSet * results = [da executeQuery:stmt_share_tag, image_id_number];
    
    if ([results next]) {
        UIView * labelBackgroundView = [self createAttachedTagLabelView:tag_id_number_share withTagName:[existTagsDictionary objectForKey:[tag_id_number_share stringValue]]];
        int extra = 5;
        int labelOriginX = extra;
        int labelOriginY = extra;
        
        CGRect rect = labelBackgroundView.frame;
        rect.origin.x = labelOriginX;
        rect.origin.y = labelOriginY;
        labelBackgroundView.frame = rect;
        labelBackgroundView.hidden = !_showSettingView;
        [tagsForImageId setObject:labelBackgroundView forKey:[tag_id_number_share stringValue]];
        [targetImageView addSubview:labelBackgroundView];
    }
    [da close];
}

- (void)createSettingToolbar:(CGRect)subViewFrame {
    
    int height  = 44;
    int width   = subViewFrame.size.width;
    int originY = subViewFrame.size.height - height;
    int originX = 0;
    CGRect settingSubViewFrame = CGRectMake(originX, originY, height, width);

    UIView * settingSubView = [[UIView alloc]initWithFrame:settingSubViewFrame];

    // toolbarの表示をONにする
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    // toolbarの文字白にする
    //self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    
    // toolbarのbackground
    //self.navigationController.toolbar.translucent = YES;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;

    
    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    
    // ボタン「Share」を生成する
//    UIBarButtonItem *button = [[UIBarButtonItem alloc]
//                               initWithTitle:@"Share" style:UIBarButtonItemStyleBordered
//                               target:self action:@selector(switchShareLabel:)];
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(switchShareLabel:)];
    
    // ラベル「delete」を生成する
    UIBarButtonItem * deleteButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImage:)];
    
    // ラベル「close」を作成する
        UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeView)];
    
    // ラベル「edit」を生成する
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editImage:)];
    
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,30)];
//    lbl.backgroundColor = [UIColor clearColor];
//    lbl.textColor = [UIColor yellowColor];
//    lbl.text = @"delete";
//    UIBarButtonItem *lblbtn = [[UIBarButtonItem alloc] initWithCustomView:lbl];
//    lblbtn.width = 100.0;
    
    // toolbarにボタンとラベルをセットする
    NSArray *items =
    [NSArray arrayWithObjects:closeButton, spacer, shareButton, spacer, deleteButton, nil];
    self.toolbarItems = items;

}

- (void)switchShareLabel:(id)sender {
    //tag_id
    int tag_id = 1000; // TODO magic number
    NSNumber * tag_id_number = [NSNumber numberWithInt:tag_id];
    
    //image_id
    NSNumber * image_index = [NSNumber numberWithInt:[self getCurrentImageIndex]];
    NSNumber * image_id = [imageIds objectAtIndex:[image_index integerValue]];
    
    NSLog(@"switchShareLabel tag_id:%@ image_id:%@", tag_id_number, image_id);
    
    
    // 以下はlabelTappedとほぼ同じ処理。冗長だが今の手間を省いてコピペする
    // TODO ラベル作成用classを継承した2つのclass(classify(写真整理用)とaction(何らかのアクションを引き起こす用))とかかな
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
        //タグの情報を取得
        id deleteTargetObject = [tagsForImageId objectForKey:[tag_id_number stringValue]];
        
        //viewから消す
        [deleteTargetObject removeFromSuperview];
        
        //tagsForImageIdから消す
        [tagsForImageId removeObjectForKey:[tag_id_number stringValue]];

        //action用tagはtagIdsForImageIdには含めないのだ！
        //tagIdsForImageIdから消す
//        for (int i = tagIdsForImageId.count - 1; i >= 0; i--) {
//            NSNumber * tid = [tagIdsForImageId objectAtIndex:i];
//            if (tid == tag_id_number) {
//                [tagIdsForImageId removeObject:tid];
//            }
//        }
        
        // ラベルの位置を調整
        //[self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
        
        //DB更新
        DA * da = [DA da];
        [da open];
        NSString * stmt_delete = @"DELETE FROM tag_map where tag_id = ? AND image_id = ?";
        [da executeUpdate:stmt_delete, tag_id_number, image_id];
        [da close];
        
        return;
    }
    
    //labelを作成
    //TODO ここも子class作って処理を移譲したい
    //TODO shareは特別な画像とかにしたい
    NSString *tag_name = [[tagsDictionary objectForKey:[tag_id_number stringValue]] objectForKey:@"tag_name" ];
    NSLog(@"tag_name : %@", tag_name);
    UIView * labelBackgroundView = [self createAttachedTagLabelView:tag_id_number withTagName:tag_name];
    
    // 既存タグ情報に追加
    [tagsForImageId setObject:labelBackgroundView forKey:[tag_id_number stringValue]];
    //[tagIdsForImageId addObject:tag_id_number];
    
    // ラベルの位置を調整
    //[self arrangeTagLabelLocation:tagsForImageId withIndexes:tagIdsForImageId];
    //今は調整する必要ない ベタで指定
    int extra = 5;
    int labelHeight = 15;
    int labelWidth = 25;
    int labelOriginX = extra;
    int labelOriginY = extra;

    UIView * labelBackground = [tagsForImageId objectForKey:[tag_id_number stringValue]];
        
    CGRect rect = labelBackground.frame;
    rect.origin.x = labelOriginX;
    rect.origin.y = labelOriginY;
    labelBackground.frame = rect;
    
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


- (void) deleteImage:(id)sender {
}

- (void) editImage:(id)sender {
}

- (void) createSettingView:(NSNumber *)image_id {

    CGRect rect = self.view.bounds;
    rect.origin.x = 0;
    rect.origin.y = rect.size.height - 100 - 44; // tool barの上 44:toolbarの高さ
    rect.size.height = 100;
    
    SettingView *settingView = [[SettingView alloc]initWithFrame:rect];
    settingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    TagScrollView *tagScrollView = [[TagScrollView alloc]init];
    tagScrollView.delegate = self;
    //scrollviewの各種設定
    tagScrollView.scrollEnabled = NO;
    tagScrollView.pagingEnabled = YES;
    tagScrollView.showsHorizontalScrollIndicator = NO;
    tagScrollView.showsVerticalScrollIndicator = NO;
    tagScrollView.backgroundColor = [UIColor clearColor];
    tagScrollView.userInteractionEnabled = YES;
    
    //1ページのフレームサイズ
    int scrollViewWidth = ((50 + 10) * existTagsArray.count + 10) < self.view.bounds.size.width ? self.view.bounds.size.width : ((50 + 10) *  existTagsArray.count + 10);
    int scrollViewHeight = 40;
    int scrollViewOriginX = 5;
    int scrollViewOriginY = 55;
    
    CGRect screenRect = self.view.bounds;
    tagScrollView.frame = CGRectMake(scrollViewOriginX, scrollViewOriginY, screenRect.size.width, scrollViewHeight);
    
    //スクロールするコンテンツの縦横サイズ
    tagScrollView.contentSize = CGSizeMake(scrollViewWidth, scrollViewHeight);
    
    //ラベルを作る
    for (int i = 0; i<existTagsArray.count; i++) {
        NSDictionary * unit = [existTagsArray objectAtIndex:i];
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
    
    // settingToolbarの作成
    [self createSettingToolbar:settingView.frame];

    // commentViewの作成
    UIView * commentView = [self createCommentView:image_id];
    commentViewObject = commentView;
    
    [settingView addSubview:tagScrollView];
    [settingView addSubview:commentView];
    [self.view addSubview:settingView];
    settingViewObject = settingView;
}

- (void) releaseRedundantImage:(NSMutableArray *)index_list withSelfIndex:selfIndex {
    NSMutableDictionary * index_dictionary = [[NSMutableDictionary alloc]init];
    for (NSNumber * index in index_list) {
        [index_dictionary setObject:@"1" forKey:[index stringValue]];
    }
    [index_dictionary setObject:@"1" forKey:[selfIndex stringValue]];
    
    NSMutableArray * keys = [addedImagesWithIndex allKeys];
    for (NSString * key in keys) {
        if ([index_dictionary objectForKey:key]) {
            continue;
        }
        //オブジェクトを破棄
        UIView * obj = [addedImagesWithIndex objectForKey:key];
        [obj removeFromSuperview];
        [addedImagesWithIndex removeObjectForKey:key];
    }
}

- (UIView *)createCommentView:(NSNumber *)image_id {
    CGRect rect = CGRectMake(5, 5, self.view.bounds.size.width, 50);
    UITextView * textView = [[UITextView alloc]initWithFrame:rect];

    DA * da = [DA da];
    [da open];
    NSString * stmt = @"SELECT comment FROM image_common WHERE id = ?";
    FMResultSet * results = [da executeQuery:stmt, image_id];
    NSString * comment = [[NSString alloc]init];
    while ([results next]) {
        comment = [results stringForColumn:@"comment"];
    }
    [da close];

    textView.text = comment;
    if (![textView hasText]) {
        textView.text = @"タップしてコメントを編集";
    }
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment = UITextAlignmentLeft;
    textView.userInteractionEnabled = YES;

    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTapped:)];
    [textView addGestureRecognizer:recognizer];

    return textView;
}

- (void)commentTapped_old:(UITapGestureRecognizer *) recognizer{
    UITextView * view = recognizer.view;
    NSLog(@"comentTapped comment:%@", view.text);

    CGRect rect = self.view.bounds;
    UIScrollView * commentEditScrollView = [[UIScrollView alloc]initWithFrame:rect];
    commentEditScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    CGRect textRect = rect;
    textRect.size.width  = rect.size.width / 1.5;
    textRect.size.height = rect.size.width / 2;
    textRect.origin.y = (rect.size.height - textRect.size.height) / 2;
    UITextView * textView = [[UITextView alloc]initWithFrame:textRect];
    textView.text = view.text;
    textView.editable = YES;
    textView.textAlignment = UITextAlignmentLeft;
    [textView becomeFirstResponder];

    [commentEditScrollView addSubview:textView];
    NSLog(@"attache commentEditScrollView %@", commentEditScrollView);
   
    [self.view addSubview:commentEditScrollView];
}

- (void)commentTapped:(UITapGestureRecognizer *) recognizer {
    UITextView * view = recognizer.view;

    NSString * text = view.text;
    CommentEditViewController * commentEditViewController = [[CommentEditViewController alloc] init];
    [commentEditViewController setComment:text];
    
    // image_id
    NSNumber * image_index = [NSNumber numberWithInt:[self getCurrentImageIndex]];
    NSNumber * image_id = [imageIds objectAtIndex:[image_index integerValue]];
    
    [commentEditViewController setImageId:image_id];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:commentEditViewController];
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self presentModalViewController:navigationController animated:YES];
}

- (void)replaceComment:(NSNumber *)image_id_number {
    DA * da = [DA da];
    NSString * stmt = @"SELECT comment FROM image_common WHERE id = ?";
    [da open];
    FMResultSet * results = [da executeQuery:stmt, image_id_number];
    NSString * comment = [[NSString alloc]init];
    while ([results next]) {
        comment   = [results stringForColumn:@"comment"];
    }
    [da close];
    commentViewObject.text = comment;
}

@end
