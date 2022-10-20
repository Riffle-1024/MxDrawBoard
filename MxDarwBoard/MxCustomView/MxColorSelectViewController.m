//
//  MxColorSelectViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/24.
//

#import "MxColorSelectViewController.h"


@interface MxColorSelectViewController ()<UIPopoverPresentationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)NSArray *colorArray;

@property(nonatomic,strong)UIView *currentColorView;



@end

@implementation MxColorSelectViewController

-(instancetype)initWithColorArray:(NSArray *)colorArray{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
        if (self.colorArray) {
            self.colorArray = [colorArray copy];
        }else{
            self.colorArray = @[@(0xFF0000),@(0x800080),@(0x00FFFF),@(0xFFFF00),@(0x0000FF),@(0x00FF00),@(996633),@(0xFF00FF),@(0xAAFF00),@(0xFFBA4D)];
        }
        self.selectedColor = [UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorWithAlphaFromRGB(0x000000, 1);
    self.preferredContentSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(202), FIT_TO_IPAD_VER_VALUE(186));
    [self initSubView];
}

-(void)initSubView{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(16), FIT_TO_IPAD_VER_VALUE(12), FIT_TO_IPAD_VER_VALUE(50), FIT_TO_IPAD_VER_VALUE(30))];
    textLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(24)];
    textLabel.text = @"颜色";
    textLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:textLabel];
 
    self.currentColorView = [[UIView alloc]initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(156), FIT_TO_IPAD_VER_VALUE(16), FIT_TO_IPAD_VER_VALUE(30), FIT_TO_IPAD_VER_VALUE(20))];
    self.currentColorView.backgroundColor = self.selectedColor;
    [self.view addSubview:self.currentColorView];
    
    
    
    [self.view addSubview:[self collectionView]];
}


-(UICollectionView *)collectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置item的行间距和列间距
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
            // 设置item的大小
    layout.itemSize = CGSizeMake(FIT_TO_IPAD_VER_VALUE(39), FIT_TO_IPAD_VER_VALUE(50));
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(4), FIT_TO_IPAD_VER_VALUE(68), FIT_TO_IPAD_VER_VALUE(195), FIT_TO_IPAD_VER_VALUE(50) * self.colorArray.count/5) collectionViewLayout:layout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    return collectionView;
}

#pragma mark - UICollectionViewDataDelegate-
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colorArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //创建item 从缓存池中拿 Item
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    if(!cell){
        cell = [[UICollectionViewCell alloc] init];
    }
    int colorValue = [[self.colorArray objectAtIndex:indexPath.row] intValue];
    cell.backgroundColor = UIColorFromRGB(colorValue);
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int colorValue = [[self.colorArray objectAtIndex:indexPath.row] intValue];
    self.selectedColor = UIColorFromRGB(colorValue);
    self.currentColorView.backgroundColor = self.selectedColor;
    if ([self.delegate respondsToSelector:@selector(didSelectColor:)]) {
        [self.delegate didSelectColor:self.selectedColor];
    }
}
@end
