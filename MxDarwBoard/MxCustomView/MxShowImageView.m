//
//  MxShowImageView.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/6/14.
//

#import "MxShowImageView.h"
#import "UILabel+Space.h"

@interface MxShowImageView()

@property(nonatomic,strong) UIImageView *showIamgeView;

@property(nonatomic,strong) UIImageView *qrImageView;

//@property(nonatomic,strong) UIButton *saveImageBtn;
//
//@property(nonatomic,strong) UIButton *saveQrCodeBtn;

@property(nonatomic,strong) UIButton *closeBtn;

@property(nonatomic,strong) UIImage *showImage;

@property(nonatomic,strong) UIImage *codeImage;

@end

@implementation MxShowImageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.showIamgeView = [[UIImageView alloc] init];
        [self addSubview:self.showIamgeView];
        self.qrImageView = [[UIImageView alloc] init];
        [self addSubview:self.qrImageView];
        [self layoutSubview];
        
    }
    return self;
}


-(void)layoutSubview{
    
    self.showIamgeView.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(17), FIT_TO_IPAD_VER_VALUE(17), FIT_TO_IPAD_VER_VALUE(308), FIT_TO_IPAD_VER_VALUE(666));
    self.qrImageView.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(428), FIT_TO_IPAD_VER_VALUE(315), FIT_TO_IPAD_VER_VALUE(170), FIT_TO_IPAD_VER_VALUE(170));
    
    UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(428), FIT_TO_IPAD_VER_VALUE(497), FIT_TO_IPAD_VER_VALUE(170), FIT_TO_IPAD_VER_VALUE(13))];
    textLabel1.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
    textLabel1.textColor = [UIColor grayColor];
    textLabel1.text = @"1.打开微信扫描二维码";
    textLabel1.textAlignment = NSTextAlignmentCenter;
    [self addSubview:textLabel1];
    
    UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(428), FIT_TO_IPAD_VER_VALUE(520), FIT_TO_IPAD_VER_VALUE(170), FIT_TO_IPAD_VER_VALUE(13))];
    textLabel2.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
    textLabel2.textColor = [UIColor grayColor];
    textLabel2.text = @"2.长按图片保存至手机";
    textLabel2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:textLabel2];
    
    UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(428), FIT_TO_IPAD_VER_VALUE(543), FIT_TO_IPAD_VER_VALUE(170), FIT_TO_IPAD_VER_VALUE(13))];
    textLabel3.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
    textLabel3.textColor = [UIColor grayColor];
    textLabel3.text = @"3.朋友圈晒出你的杰作";
    textLabel3.textAlignment = NSTextAlignmentCenter;
    [self addSubview:textLabel3];
    
  
//
//    UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(445), FIT_TO_IPAD_VER_VALUE(497), FIT_TO_IPAD_VER_VALUE(200), FIT_TO_IPAD_VER_VALUE(50))];
//    textLabel.font = [UIFont systemFontOfSize:FIT_TO_IPAD_VER_VALUE(12)];
//    textLabel.textColor = [UIColor grayColor];
//    textLabel.numberOfLines = 0;
////    textLabel.text = @"1.打开微信扫描二维码\n2.长按图片保存至手机\n3.朋友圈晒出你的杰作";
//    textLabel.textAlignment = NSTextAlignmentCenter;
////    [UILabel changeSpaceForLabel:textLabel withLineSpace:8 WordSpace:2];//设置testLabel中内容的行间距为20，
//    [self addSubview:textLabel];
//
//
//    NSString * lableText = @"1.打开微信扫描二维码\n2.长按图片保存至手机\n3.朋友圈晒出你的杰作";
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lableText];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//
//    [paragraphStyle setLineSpacing:6];//调整行间距
//
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lableText length])];
//    textLabel.attributedText = attributedString;
//    [textLabel sizeToFit];
    
//    self.saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.saveImageBtn setTitle:@"保存作品到相册" forState:UIControlStateNormal];
//    [self.saveImageBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [self.saveImageBtn setBackgroundColor:[UIColor blueColor]];
//    self.saveImageBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(391), FIT_TO_IPAD_VER_VALUE(545.5), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(20));
//    [self.saveImageBtn addTarget:self action:@selector(saveImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.saveImageBtn];
//
//    self.saveQrCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.saveQrCodeBtn setTitle:@"保存二维码到相册" forState:UIControlStateNormal];
//    [self.saveQrCodeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [self.saveQrCodeBtn setBackgroundColor:[UIColor blueColor]];
//    self.saveQrCodeBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(564), FIT_TO_IPAD_VER_VALUE(545.5), FIT_TO_IPAD_VER_VALUE(150), FIT_TO_IPAD_VER_VALUE(20));
//    [self.saveQrCodeBtn addTarget:self action:@selector(saveCodeImageBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.saveQrCodeBtn];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    
    [self.closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.closeBtn.frame = CGRectMake(FIT_TO_IPAD_VER_VALUE(658), FIT_TO_IPAD_VER_VALUE(17), FIT_TO_IPAD_VER_VALUE(25), FIT_TO_IPAD_VER_VALUE(25));
    [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage imageNamed:@"icon-cancel"] forState:UIControlStateNormal];
    [self addSubview:self.closeBtn];
    
    
    UIImageView *textImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FIT_TO_IPAD_VER_VALUE(395), FIT_TO_IPAD_VER_VALUE(143), FIT_TO_IPAD_VER_VALUE(272), FIT_TO_IPAD_VER_VALUE(182))];
    textImageView.image = [UIImage imageNamed:@"share_text_Image"];
    [self addSubview:textImageView];
}

-(void)updateShowImage:(UIImage *)image AndQrCodeImage:(UIImage *)codeImage{
    self.showIamgeView.image = image;
    self.qrImageView.image = codeImage;
    self.showImage = image;
    self.codeImage = codeImage;
}



-(void)saveImageBtnClick{
    UIImageWriteToSavedPhotosAlbum(self.showImage,  self,  @selector(image:didFinishSavingWithError:contextInfo:),  (__bridge  void  *)self);
}

-(void)saveCodeImageBtnClick{
    UIImageWriteToSavedPhotosAlbum(self.codeImage,  self,  @selector(image:didFinishSavingWithError:contextInfo:),  (__bridge  void  *)self);
}

-  (void)image:(UIImage  *)image  didFinishSavingWithError:(NSError  *)error  contextInfo:(void  *)contextInfo

{

    DLog(@"image  =  %@,  error  =  %@,  contextInfo  =  %@",  image,  error,  contextInfo);

}

-(void)closeBtnClick{
    self.hidden = YES;
}




@end
