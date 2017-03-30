//
//  ViewController.m
//  GPUImage_WHC_02(groupFilter)
//
//  Created by Dustin on 17/3/30.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()

@property (nonatomic,strong)GPUImageFilterGroup *myFilterGroup;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"image.jpg"];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
    
    [picture addTarget:self.myFilterGroup];
    //反色滤镜
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    [self addGPUImageFilter:invertFilter];
    
//    //彩色矩阵滤镜
//    GPUImageColorMatrixFilter *colorMatrixFilter = [[GPUImageColorMatrixFilter alloc] init];
//    colorMatrixFilter.colorMatrix = (GPUMatrix4x4){
//        {1.f, 0.f, 1.f, 0.f},
//        {0.f, 1.f, 0.f, 0.f},
//        {0.f, 0.f, 1.f, 0.f},
//        {0.f, 1.f, 0.f, 1.f}
//    };
//    colorMatrixFilter.intensity = 0.3;
//    
//    [self addGPUImageFilter:colorMatrixFilter];
    
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc]init];
    gammaFilter.gamma = 0.2;
    [self addGPUImageFilter:gammaFilter];
    
    //曝光度滤镜
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc]init];
    exposureFilter.exposure = -1.0;
    [self addGPUImageFilter:exposureFilter];
    
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    [self addGPUImageFilter:sepiaFilter];
    
    //处理图片
    [picture processImage];
    [self.myFilterGroup useNextFrameForImageCapture];
    
    //拿到处理后的图片
    UIImage *dealedImage = [self.myFilterGroup imageFromCurrentFramebuffer];
    
    self.myImageView.image = dealedImage;
}

#pragma mark 将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageFilter *)filter{
    
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

@end
