//
//  DevelopShowImageViewController.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/3/9.
//

#import "DevelopShowImageViewController.h"

@interface DevelopShowImageViewController ()

@end

@implementation DevelopShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.showImage.size.width < self.view.frame.size.width ? self.showImage.size.width :  self.view.frame.size.width, self.showImage.size.height < self.view.frame.size.height ? self.showImage.size.height :  self.view.frame.size.height)];
    scrollView.contentSize = self.showImage.size;
    [self.view addSubview:scrollView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.showImage.size.width, self.showImage.size.height)];
    imageView.image = self.showImage;
    [scrollView addSubview:imageView];
    
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(exitViewController:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(savePhoto:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}


-(void)exitViewController:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)savePhoto:(UIButton *)sender{
     UIImageWriteToSavedPhotosAlbum(self.showImage,  self,  @selector(image:didFinishSavingWithError:contextInfo:),  (__bridge  void  *)self);

}

-  (void)image:(UIImage  *)image  didFinishSavingWithError:(NSError  *)error  contextInfo:(void  *)contextInfo

{

    DLog(@"image  =  %@,  error  =  %@,  contextInfo  =  %@",  image,  error,  contextInfo);

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
