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
@property (weak, nonatomic) IBOutlet UIImageView *image;

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
    
    if (!_image) {
        [_image setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    return _image;
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
    /*
    // 人脸检测
    [sdk detectFace:image successBlock:^(id responseObject) {
        NSLog(@"responseObject11: %@", responseObject);
    } failureBlock:^(NSError *error) {
        NSLog(@"error11");
    }];
    
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
    [sdk faceShape:image successBlock:^(id responseObject) {
        NSLog(@"faceShape: %@", responseObject);
    } failureBlock:^(NSError *error) {
        
    }];
}

//从相册选择
-(void)LocalPhoto{
    NSLog(@"aaa LocalPhoto");
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//拍照
-(void)takePhoto{
    NSLog(@"aaa takePhoto");
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
            NSLog(@"takephoto");
            [self takePhoto];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"photoLibrary");
            [self LocalPhoto];
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
    [self.image setImage:image];
    [self analyseImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end