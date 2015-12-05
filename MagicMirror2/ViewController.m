//
//  ViewController.m
//  AVFoundationCamera
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Conf.h"
#import "Auth.h"
#import "TXQcloudFrSDK.h"

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

//带界面的语音识别控件
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"

#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, IFlySpeechSynthesizerDelegate>
{
    IFlySpeechSynthesizer *_iFlySpeechSynthesizer;
}

@property (strong, nonatomic) UIAlertController *actionSheet;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation ViewController

#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    [self addGenstureRecognizer];
}

- (void)initNavigationBar {
    UIBarButtonItem *choosePhoto = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(choosePhoto)];
    
    NSArray * rightButtons = [[NSArray alloc] initWithObjects:choosePhoto, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
#pragma mark 私有方法
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(UIImageView *)image {
    
    if (!_imageView) {
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    return _imageView;
}

#pragma mark - UI方法
#pragma mark - speak
//
//  @function:          合成语音信息
//  @param - speed:     语速 0~100
//  @param - volume:    音量 0~100
//  @param - voiceName: 发音人，默认为“xiaoyan”；可以设置多个参数列表
//  @param - message:   将要说的信息
//
- (void)speakMessage:(NSString *)speed Volume:(NSString *)volume VoiceName:(NSString *)voiceName Message:(NSString *)message {
    // 创建合成对象，为单例模式
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    //设置语音合成的参数
    [_iFlySpeechSynthesizer setParameter:speed forKey:[IFlySpeechConstant SPEED]];
    [_iFlySpeechSynthesizer setParameter:volume forKey: [IFlySpeechConstant VOLUME]];
    [_iFlySpeechSynthesizer setParameter:voiceName forKey: [IFlySpeechConstant VOICE_NAME]];
    //音频采样率,目前支持的采样率有 16000 和 8000
    [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    //asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    //[_iFlySpeechSynthesizer setParameter:@" tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    //启动合成会话
    [_iFlySpeechSynthesizer startSpeaking: message];
}

#pragma mark - 分析照片
- (void)analyseImage:(UIImage *)image{
    
    NSLog(@"Analyse Image.");
    [Conf instance].appId = @"1003944";
    [Conf instance].secretId = @"AKIDqVlfkOUMjhRaIfdiQtcVwVvJPIh1lauc";
    [Conf instance].secretKey = @"aiw9FPW6C2tkT6JYmwm4lyv5OAs4Fbgc";
    
    NSString *auth = [Auth appSign:1000000 userId:nil];
    TXQcloudFrSDK *sdk = [[TXQcloudFrSDK alloc] initWithName:[Conf instance].appId authorization:auth];
    
    sdk.API_END_POINT = @"http://api.youtu.qq.com/youtu";
    
    // 人脸检测,判断检测人脸是否成功
    [sdk detectFace:image successBlock:^(id responseObject) {
        if ([responseObject[@"errorcode"] intValue] == 0) {
            NSLog(@"检测人脸成功...");
            
            int x       = [responseObject[@"face"][0][@"x"] intValue];
            int y       = [responseObject[@"face"][0][@"y"] intValue];
            int width   = [responseObject[@"face"][0][@"width"] intValue];
            int height  = [responseObject[@"face"][0][@"height"] intValue];
            
            CGRect faceRect = CGRectMake(x,
                                         y,
                                         width,
                                         height );
            
            CGPoint textPoint = CGPointMake(x + width,
                                            y);
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"年龄:%@", responseObject[@"face"][0][@"age"]], @"age",
                                 [NSString stringWithFormat:@"性别:%@", responseObject[@"face"][0][@"gender"]], @"gender",
                                 [NSString stringWithFormat:@"表情:%@", responseObject[@"face"][0][@"expression"]], @"expression",
                                 [NSString stringWithFormat:@"魅力:%@", responseObject[@"face"][0][@"beauty"]], @"beauty",
                                 nil];
            
            UIImage *afterDrawedImage = [self imageByDrawingCircleOnImage:image forRect:faceRect text:dic textForPoint:textPoint];
            [self.indicator stopAnimating];
            [self.imageView setImage:afterDrawedImage];
        }
        else
        {
            NSLog(@"检测人脸失败...");
            [self.indicator stopAnimating];
            return ;
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"error11");
    }];
    //
    [sdk faceShape:image successBlock:^(id responseObject) {
        NSLog(@"faceShape: %@", responseObject);
    } failureBlock:^(NSError *error) {
        
    }];
    
    /*
    [sdk idcardOcr:image cardType:1 sessionId:nil successBlock:^(id responseObject) {
        NSLog(@"responseObject22: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error22");
    }];
    // 图像标签服务
    [sdk imageTag:image cookie:nil seq:nil successBlock:^(id responseObject) {
        NSLog(@"responseObject33: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error33");
    }];
    [sdk imagePorn:image cookie:nil seq:nil successBlock:^(id responseObject) {
        NSLog(@"responseObject44: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error44");
    }];
    // 美食照片检测
    [sdk foodDetect:image cookie:nil seq:nil successBlock:^(id responseObject) {
        NSLog(@"responseObject55: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error55");
    }];
    // 模糊照片检测
    [sdk fuzzyDetect:image cookie:nil seq:nil successBlock:^(id responseObject) {
        NSLog(@"responseObject66: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error66");
    }];
    
    */
}

//从相册选择
-(void)LocalPhoto{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//拍照
-(void)takePhoto{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];

    }else {
        NSLog(@"该设备无摄像头");
    }
}

- (void)choosePhoto {
    
    [self presentViewController:self.actionSheet
                       animated:YES
                     completion:nil];
}

- (UIAlertController *)actionSheet
{
    if (_actionSheet == nil) {
        _actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                           message:nil
                                                    preferredStyle:UIAlertControllerStyleActionSheet];
        // 在action sheet中，UIAlertActionStyleCancel不起作用
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self takePhoto];
            [self.indicator startAnimating];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self LocalPhoto];
            [self.indicator startAnimating];
        }];
        UIAlertAction *act3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        [_actionSheet addAction:act1];
        [_actionSheet addAction:act2];
        [_actionSheet addAction:act3];
    }
    return _actionSheet;
}

#pragma mark - 私有方法

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    /*
    UITapGestureRecognizer *singleTapGestureFocuse=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [singleTapGestureFocuse setNumberOfTapsRequired:1];
    [self.viewContainer addGestureRecognizer:singleTapGestureFocuse];
    
    UITapGestureRecognizer *doubleTapGestureTakePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhotoAction)];
    [doubleTapGestureTakePhoto setNumberOfTapsRequired:2];
    [self.viewContainer addGestureRecognizer:doubleTapGestureTakePhoto];
    [singleTapGestureFocuse requireGestureRecognizerToFail:doubleTapGestureTakePhoto];
    */
}

//
//  在Image上圈出头部，并弹出年龄、性别、表情、魅力
//
//
- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image forRect:(CGRect )rect text:(NSDictionary *)textDic textForPoint:(CGPoint)point
{
    UIGraphicsBeginImageContext(image.size);            // begin a graphics context of sufficient size
    [image drawAtPoint:CGPointZero];                    // draw original image into the context
    CGContextRef ctx = UIGraphicsGetCurrentContext();   // get the context for CoreGraphics
    [[UIColor redColor] setStroke];                     // set stroking color and draw rect
    rect = CGRectInset(rect, 5, 5);
    CGContextStrokeRect(ctx, rect);

    UIFont *font = [UIFont systemFontOfSize:35.0];
    UIColor *textColor =[UIColor blackColor];
    NSDictionary *dicAttribute = @{
                                   NSFontAttributeName:font,
                                   NSForegroundColorAttributeName:textColor,
                                   NSBackgroundColorAttributeName:[UIColor colorWithRed:85 green:238 blue:180 alpha:1.0],
                                   
                                   };
    
    [textDic[@"age"] drawAtPoint:point withAttributes:dicAttribute];
    [textDic[@"gender"] drawAtPoint:CGPointMake(point.x, point.y+50) withAttributes:dicAttribute];
    [textDic[@"expression"] drawAtPoint:CGPointMake(point.x, point.y+100) withAttributes:dicAttribute];
    [textDic[@"beauty"] drawAtPoint:CGPointMake(point.x, point.y+150) withAttributes:dicAttribute];
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();    // make image out of bitmap context
    UIGraphicsEndImageContext();                                        // free the context
    
    return retImage;
}

#pragma mark 讯飞 delegate

// 合成结束，此代理必须实现
-(void)onCompleted:(IFlySpeechError *)error {
    
}
// 合成开始
-(void)onSpeakBegin{
    
}
// 合成进度
-(void)onBufferProgress:(int)progress message:(NSString *)msg {
    
}
// 合成播放进度
-(void)onSpeakProgress:(int)progress {
    
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image;
    //如果允许编辑则获得编辑后的照片，否则获取原始照片
    if (self.imagePicker.allowsEditing) {
        image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
    }else{
        image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
    }
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self analyseImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end