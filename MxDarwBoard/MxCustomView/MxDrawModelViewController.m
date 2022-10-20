//
//  MxDrawModelViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/25.
//

#import "MxDrawModelViewController.h"
#import "DevelopManager.h"
#import "DarwModelViewCell.h"

@interface MxDrawModelViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIPopoverPresentationControllerDelegate>

@property(nonatomic,copy)NSArray *localProductArray;

@property(nonatomic,assign)NSInteger selectIndex;

@property(nonatomic,strong)UICollectionView *collectionView;

@property(nonatomic,strong)DarwModelViewCell *selecedCell;

@end

@implementation MxDrawModelViewController

-(instancetype)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.2);
    self.localProductArray = [DevelopManager getLocalProductArray];
    if (self.localProductArray.count) {
        [self saveData];
//        [self saveImage];
    }else{
        [self getProductFromPlist];
    }
    
    self.preferredContentSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(200), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(100));
    [self getAllModePoint];
    [self initSubView];
}

-(void)saveData{
    NSArray  *pathes     = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path       = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
    NSString *finishPath = [NSString stringWithFormat:@"%@/MxDraw/product/",path];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:finishPath]) {
        [fileManager createDirectoryAtPath:finishPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //假设我们需往cache 存入数据，并命名为test的txt格式文件中
        NSString *filePath = [finishPath stringByAppendingPathComponent:@"product.plist"];
    NSError *error;
    BOOL rvm = [fileManager removeItemAtPath:filePath error:&error];
//    NSArray *dic = [[NSArray alloc] initWithObjects:@"test",@"test1" ,nil];
    BOOL success = [self.localProductArray writeToFile:filePath atomically:YES];
    if(success){
            NSLog(@"存入成功");
    }else{
        NSLog(@"存入失败");
    }
        //取出数据 打印
        NSLog(@"%@",[NSArray arrayWithContentsOfFile:filePath]);
}

-(void)getProductFromPlist{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"product" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    if (array.count) {
        self.localProductArray = array;
        for (NSDictionary * locationInfo in array) {
            NSArray *location = [locationInfo objectForKey:@"locationArray"];
            NSString *imageKey = [locationInfo objectForKey:@"imageKey"];
            UIImage *image = [UIImage imageNamed:imageKey];
            [DevelopManager saveLocationArrayWithNewArray:location Image:image];
        }
    }
}
    
-(void)saveImage{
    for (NSDictionary *locationInfo in self.localProductArray) {
        NSString * imageKey = [locationInfo objectForKey:@"imageKey"];
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:imageKey];
        UIImage* image = [UIImage imageWithData:imageData];
        [DevelopManager saveImageToCache:image ImageKey:imageKey];
    }
}

-(void)initSubView{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(16), FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(80), FIT_TO_IPAD_VER_VALUE(40))];
    titleLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(24)];
    titleLabel.text = @"图案";
    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:titleLabel];
    [self.view addSubview:self.collectionView];
    if (self.isDebug) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveAction:)];
        self.collectionView.userInteractionEnabled = YES;
        [self.collectionView addGestureRecognizer:longPressGesture];
    }
}


- (void)moveAction:(UILongPressGestureRecognizer *)longGes {
    if (longGes.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *selectPath = [self.collectionView indexPathForItemAtPoint:[longGes locationInView:longGes.view]];
        DarwModelViewCell *cell = (DarwModelViewCell *)[self.collectionView cellForItemAtIndexPath:selectPath];
        cell.deleteBtn.hidden = NO;
        [cell.deleteBtn addTarget:self action:@selector(deleteItemAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteBtn.tag = selectPath.item;
        [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectPath];
    }else if (longGes.state == UIGestureRecognizerStateChanged) {
        [self.collectionView updateInteractiveMovementTargetPosition:[longGes locationInView:longGes.view]];
    }else if (longGes.state == UIGestureRecognizerStateEnded) {
        [self.collectionView endInteractiveMovement];
    }else {
        [self.collectionView cancelInteractiveMovement];
    }
}

- (void)deleteItemAction:(UIButton *)btn {
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.localProductArray];
    [newArray removeObjectAtIndex:btn.tag];
    [DevelopManager deleteLocationArrayWithIndex:(int)btn.tag];
    self.localProductArray = newArray;
    [self.collectionView reloadData];
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 设置item的行间距和列间距
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 4;
                // 设置item的大小
        layout.itemSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(190));
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, FIT_TO_IPAD_VER_VALUE(60), FIT_TO_IPAD_VER_VALUE(200), Screen_HEIGHT - FIT_TO_IPAD_VER_VALUE(160)) collectionViewLayout:layout];
        [collectionView registerClass:[DarwModelViewCell class] forCellWithReuseIdentifier:@"DarwModelViewCell"];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 0.2);
        _collectionView = collectionView;
    }
    

    return _collectionView;
}

#pragma mark - UICollectionViewDataDelegate-
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.localProductArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //创建item 从缓存池中拿 Item
    DarwModelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DarwModelViewCell" forIndexPath:indexPath];
    if(!cell){
        cell = [[DarwModelViewCell alloc] init];
    }else{
        [cell refleshView];
    }
    cell.titleString = [NSString stringWithFormat:@"第%ld图",indexPath.row];
    NSDictionary *locationData = [self.localProductArray objectAtIndex:indexPath.row];
//    [cell updateViewWithLocationArray:locationArray];
    [cell updateViewWithLocationData:locationData];
    return cell;

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selecedCell) {
        [self.selecedCell isSelected:NO];
    }
    DarwModelViewCell *cell = (DarwModelViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell isSelected:YES];
    self.selecedCell = cell;
    NSDictionary *locationData = [self.localProductArray objectAtIndex:indexPath.row];
    NSArray *locationArray = [locationData objectForKey:@"locationArray"];
    if ([self.delegate respondsToSelector:@selector(didSelectLocationArray:)]) {
        [self.delegate didSelectLocationArray:locationArray];
    }
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.localProductArray];
    
    id obj = newArray[sourceIndexPath.item];
    [newArray removeObjectAtIndex:sourceIndexPath.item];
    [newArray insertObject:obj atIndex:destinationIndexPath.item];
    self.localProductArray = newArray;
    [DevelopManager updateAllProductData:newArray];
    [self.collectionView reloadData];
}
-(void)getAllModePoint{
    for (int i = 0; i < 400; i++) {
        NSInteger pointX = FIT_TO_IPAD_VER_VALUE(3.75) + i % 20 *FIT_TO_IPAD_VER_VALUE(7.5);
        NSInteger pointY = FIT_TO_IPAD_VER_VALUE(3.75) + i/20 * FIT_TO_IPAD_VER_VALUE(7.5);
        CGPoint point = CGPointMake(pointX, pointY);
        [[DevelopManager shareInstance].modelPointList addObject:NSStringFromCGPoint(point)];
    }
}

//- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController API_DEPRECATED_WITH_REPLACEMENT("presentationControllerShouldDismiss:", ios(8.0, 13.0)){
//    return NO;
//}

@end
