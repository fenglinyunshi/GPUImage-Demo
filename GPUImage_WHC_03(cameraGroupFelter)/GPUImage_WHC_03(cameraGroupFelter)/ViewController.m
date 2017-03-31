//
//  ViewController.m
//  GPUImage_WHC_03(cameraGroupFelter)
//
//  Created by Dustin on 17/3/30.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import <Photos/Photos.h>

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property(strong,nonatomic)GPUImageStillCamera *myCamera;
@property(strong,nonatomic)GPUImageView *myGPUImageView;
@property(strong,nonatomic)GPUImageFilter *myFilter;
@property(copy,nonatomic)NSArray *filterArr;
@property(weak,nonatomic)UISlider *mySlider;
@property(strong,nonatomic)UIButton *selectedBtn;
@property(strong,nonatomic)GPUImageFilterGroup *myFilterGroup;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化相机，第一个参数表示相册的尺寸，第二个参数表示前后摄像头
    self.myCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    
    //竖屏方向
    self.myCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    //初始化filterGroup
    self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
    
    //哈哈镜效果
    GPUImageStretchDistortionFilter *stretchDistortionFilter = [[GPUImageStretchDistortionFilter alloc] init];
    
    //亮度
    GPUImageBrightnessFilter *BrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    
    //边缘检测
    GPUImageXYDerivativeFilter *XYDerivativeFilter = [[GPUImageXYDerivativeFilter alloc] init];
    
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    //反色
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    
    //饱和度
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    
    //美颜
    GPUImageBeautifyFilter *beautyFielter = [[GPUImageBeautifyFilter alloc] init];
    
    //初始化滤镜数组
    self.filterArr = @[stretchDistortionFilter,BrightnessFilter,gammaFilter,XYDerivativeFilter,sepiaFilter,invertFilter,saturationFilter,beautyFielter];
    
    [self addGPUImageFilter:BrightnessFilter];
//    [self addGPUImageFilter:sepiaFilter];
//    [self addGPUImageFilter:beautyFielter];
//    [self addGPUImageFilter:stretchDistortionFilter];
//    [self addGPUImageFilter:XYDerivativeFilter];
    //初始化GPUImageView
    self.myGPUImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
    
    self.myFilter = BrightnessFilter;
    
    [self.view addSubview:self.myGPUImageView];
    [self.myCamera startCameraCapture];
    
    //初始设置为哈哈镜效果
    [self.myCamera addTarget:self.myFilterGroup];
    [self.myFilterGroup addTarget:self.myGPUImageView];
    //创建UI
    [self creatUI];
}

- (void)creatUI{
    //风格按钮
    NSArray *titleArr = @[@"哈哈镜",@"亮度",@"伽马线",@"边缘检测",@"怀旧",@"反色",@"饱和度",@"美颜"];
    for (int i = 0; i < 8; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 40+i*40, 80, 30);
        btn.layer.cornerRadius = 5;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        btn.alpha = 0.6;
        btn.tag = i + 100;
        [btn addTarget:self action:@selector(filterStyleIsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        if (1 == i) {
            _selectedBtn = btn;
            [btn setBackgroundColor:[UIColor blueColor]];
        }
    }
    
    //照相的按钮
    UIButton *catchImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    catchImageBtn.frame = CGRectMake((ScreenW-60)/2, ScreenH-80, 60, 60);
    [catchImageBtn addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [catchImageBtn setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    [self.view addSubview:catchImageBtn];
    
    // UISlider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake((ScreenW-200)/2, ScreenH-130, 200, 30)];
    slider.value = 0.5;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    _mySlider = slider;
    
    //切换前后摄像机
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    switchBtn.frame = CGRectMake(ScreenW-60, 30, 44, 35);
    [switchBtn setImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchIsChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:switchBtn];
}

//选择照片的风格
- (void)filterStyleIsClicked:(UIButton *)sender {
    
    [self.selectedBtn setBackgroundColor:[UIColor lightGrayColor]];
    [sender setBackgroundColor:[UIColor blueColor]];
    self.mySlider.value = 0.5;
    if (3 == (sender.tag-100) || 4 == (sender.tag-100) || 5 == (sender.tag-100) || 7 == (sender.tag-100)) {
        self.mySlider.hidden = YES;
    }else{
        self.mySlider.hidden = NO;
    }
    GPUImageFilter *filter = self.filterArr[sender.tag-100];

    [self addGPUImageFilter:filter];
    
    [self.myFilterGroup removeAllTargets];
    [self.myCamera removeAllTargets];
    
    [self.myCamera addTarget:self.myFilterGroup];
    [self.myFilterGroup addTarget:self.myGPUImageView];
    
    _selectedBtn = sender;
}

//将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageOutput *)filter{
    
    [self.myFilterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = self.myFilterGroup.filterCount;
    
    if (count == 1)
    {
        self.myFilterGroup.initialFilters = @[newTerminalFilter];
        self.myFilterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = self.myFilterGroup.terminalFilter;
        NSArray *initialFilters                          = self.myFilterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        self.myFilterGroup.initialFilters = @[initialFilters[0]];
        self.myFilterGroup.terminalFilter = newTerminalFilter;
    }
}


//滑动slider滚动条
- (void)sliderValueChanged:(UISlider *)slider{
    if([self.myFilter isKindOfClass:[GPUImageStretchDistortionFilter class]]){
        GPUImageStretchDistortionFilter *filter = (GPUImageStretchDistortionFilter*)self.myFilter;
        //The center about which to apply the distortion, with a default of (0.5, 0.5)
        filter.center = CGPointMake(slider.value, 0.5);
    }else if ([self.myFilter isKindOfClass:[GPUImageBrightnessFilter class]]){
        // Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
        GPUImageBrightnessFilter *filter = (GPUImageBrightnessFilter*)self.myFilter;
        filter.brightness = slider.value*2-1;
    }else if ([self.myFilter isKindOfClass:[GPUImageGammaFilter class]]){
        GPUImageGammaFilter *filter = (GPUImageGammaFilter*)self.myFilter;
        // Gamma ranges from 0.0 to 3.0, with 1.0 as the normal level
        filter.gamma = slider.value*3;
    }else if ([self.myFilter isKindOfClass:[GPUImageSaturationFilter class]]){
        GPUImageSaturationFilter *filter = (GPUImageSaturationFilter*)self.myFilter;
        //Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
        filter.saturation = slider.value*2;
    }
}

//切换前后镜头
- (void)switchIsChanged:(UIButton *)sender {
    [self.myCamera rotateCamera];
}

//开始拍照
- (void)capturePhoto:(UIButton *)sender {
    //定格一张图片 保存到相册
    [self.myCamera capturePhotoAsPNGProcessedUpToFilter:self.myFilter withCompletionHandler:^(NSData *processedPNG, NSError *error) {
        
        //拿到相册，需要引入Photo Kit
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入图片到相册
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:processedPNG]];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            NSLog(@"success = %d, error = %@", success, error);
            
        }];
        
    }];
}


@end

