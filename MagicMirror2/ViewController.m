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

#import "Constant.h"
#import "IATConfig.h"
#import "TalkRequest.h"

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

//带界面的语音识别控件
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"

#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, IFlySpeechSynthesizerDelegate, IFlyRecognizerViewDelegate>
{
    IFlySpeechSynthesizer   *_iFlySpeechSynthesizer;
    IFlyRecognizerView      *_iflyRecognizerView;

    CGRect                  mainScreen;
}

@property (strong, nonatomic) UIAlertController *actionSheet;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *speakBtn;

@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象

@end

@implementation ViewController

#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPara];
    [self initNavigationBar];
}

- (void)initNavigationBar {
    UIBarButtonItem *choosePhoto = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(choosePhoto)];
    
    NSArray * rightButtons = [[NSArray alloc] initWithObjects:choosePhoto, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
}

- (void)initPara {
    mainScreen = [UIScreen mainScreen].bounds;
    [self.speakBtn.layer setCornerRadius:CGRectGetHeight(self.speakBtn.frame) / 2];
    
    [self initIflyRecognizerView];
}
//
// 初始化语音识别控件
//
- (void)initIflyRecognizerView
{
    if (nil != _iflyRecognizerView)
        return;
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];     // 初始化语音识别控件
    _iflyRecognizerView.delegate = self;
    
    IATConfig *instance = [IATConfig sharedInstance];
    [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];   //设置最长录音时间
    [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];                 //设置后端点
    [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];                 //设置前端点
    [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];                    //网络等待时间
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
#pragma mark - 语音听写
//
//  语音听写
//
- (IBAction)speechRecognition
{
    [_iflyRecognizerView cancel];
    
    [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];        //设置音频来源为麦克风
    [_iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter: @"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];   // 设置听写结果格式 json
    [_iflyRecognizerView start];
}

#pragma mark - 获得照片得信息
//
//  检测人脸成功之后，获得表情、年龄、性别、魅力等信息，并保持字符串长度一致
//
- (NSDictionary *)getDateByAnalysingImage:(NSDictionary *)responseObject
{
    NSMutableString *expression  = [NSMutableString stringWithString:@"表情:似笑非笑"];
    //expression  = [NSMutableString stringWithFormat:@"表情:%@", responseObject[@"face"][0][@"expression"]];
    NSString *gender;
    if ([responseObject[@"face"][0][@"gender"] intValue] > 60) {
        gender = @"性别: 男";
    } else if ([responseObject[@"face"][0][@"gender"]intValue] < 10) {
        gender = @"性别: 女";
    } else
        gender = @"性别: 难以判断";
    NSMutableString *age         = [NSMutableString stringWithFormat:@"年龄: %@", responseObject[@"face"][0][@"age"]];
    NSMutableString *beauty      = [NSMutableString stringWithFormat:@"魅力: %@", responseObject[@"face"][0][@"beauty"]];
    
    NSLog(@"age:%lu, expression:%lu", (unsigned long)age.length, (unsigned long)expression.length);
    
    if (age.length < expression.length) {
        [age stringByAppendingString:@"     "];
    }
    
    NSDictionary *res = [NSDictionary dictionaryWithObjectsAndKeys:
                         age, @"age",
                         gender, @"gender",
                         expression, @"expression",
                         beauty, @"beauty",
                         nil];
    return res;
}

//
// 智能语音聊天，反馈回消息
//
- (void)robot:(NSString *)info {
    
    TalkRequest *request = [[TalkRequest alloc] initWithInfo:info];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        NSLog(@"request: %@", [request.responseJSONObject objectForKey:@"text"]);
        [self speakMessage:@"50" Volume:@"50" VoiceName:@"xiaoyan" Message:[request.responseJSONObject objectForKey:@"text"]];
        
    } failure:^(YTKBaseRequest *request) {
        [self speakMessage:@"50" Volume:@"50" VoiceName:@"xiaoyan" Message:@"没清楚，再说一遍嘛"];
    }];
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
            
            UIImage *afterDrawedImage = [self imageByDrawingCircleOnImage:image forRect:faceRect text:[self getDateByAnalysingImage:responseObject] textForPoint:textPoint];
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
        //NSLog(@"faceShape: %@", responseObject);
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

//
// 从相册选择
//
-(void)LocalPhoto{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
//
// 拍照
//
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
            [self.imageView clearsContextBeforeDrawing];
            [self.indicator startAnimating];
        }];
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self LocalPhoto];
            [self.imageView clearsContextBeforeDrawing];
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
    [[UIColor greenColor] setStroke];                   // set stroking color and draw rect
    rect = CGRectInset(rect, 5, 5);
    CGContextStrokeRect(ctx, rect);

    NSDictionary *dicAttribute = @{
                                   NSFontAttributeName:[UIFont systemFontOfSize:30.0],
                                   NSForegroundColorAttributeName:[UIColor blackColor],
                                   NSBackgroundColorAttributeName:[UIColor cyanColor],
                                   };
    NSLog(@"point.x: %f, width:%f", point.x + rect.size.width, SCREEN_WIDTH * SCREEN_SCALE);
    if ((point.x + rect.size.width) > (SCREEN_SCALE * SCREEN_WIDTH)) {
        point.x = 10;
    }
    
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
    // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self analyseImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark IFlyRecognizerViewDelegate

-(void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    NSLog(@"result: %@", result);
    [self robot:result];
    [_iflyRecognizerView cancel];
}

-(void)onError:(IFlySpeechError *)error
{
    
}

@end