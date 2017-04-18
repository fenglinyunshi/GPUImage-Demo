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
@property (nonatomic,strong) GPUImagePicture    *picture;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (nonatomic,strong) GPUImageView        *myGpuImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载一个UIImage对象
    UIImage *image = [UIImage imageNamed:@"image.jpg"];
    
    //初始化GPUImagePicture
    _picture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    //反色滤镜
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc]init];
    gammaFilter.gamma = 0.2;
    
    //曝光度滤镜
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc]init];
    exposureFilter.exposure = -1.0;
    
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
//    /*
//     *FilterGroup的方式混合滤镜
//     */
//    //初始化GPUImageFilterGroup
//    self.myFilterGroup = [[GPUImageFilterGroup alloc] init];
//    //将滤镜组加在GPUImagePicture上
//    [_picture addTarget:self.myFilterGroup];
//    //将滤镜加在FilterGroup中
//    [self addGPUImageFilter:invertFilter];
//    [self addGPUImageFilter:gammaFilter];
//    [self addGPUImageFilter:exposureFilter];
//    [self addGPUImageFilter:sepiaFilter];
//    //处理图片
//    [_picture processImage];
//    [self.myFilterGroup useNextFrameForImageCapture];
//    //拿到处理后的图片
//    UIImage *dealedImage = [self.myFilterGroup imageFromCurrentFramebuffer];
//    self.myImageView.image = dealedImage;
    
    
    
    
    /*
     *GPUImageFilterPipeline的方式混合滤镜
     */
    
    //初始化myGpuImageView
    _myGpuImageView = [[GPUImageView alloc] initWithFrame:self.myImageView.bounds];
    [self.myImageView addSubview:self.myGpuImageView];
    
    //把多个滤镜对象放到数组中
    NSMutableArray *filterArr = [NSMutableArray array];
    [filterArr addObject:invertFilter];
    [filterArr addObject:gammaFilter];
    [filterArr addObject:exposureFilter];
    [filterArr addObject:sepiaFilter];
    
    //创建GPUImageFilterPipeline对象
    GPUImageFilterPipeline *filterPipline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:_picture output:self.myGpuImageView];
    
    //处理图片
    [_picture processImage];
    [sepiaFilter useNextFrameForImageCapture];
    
    //拿到处理后的图片
    UIImage *dealedImage = [filterPipline currentFilteredFrame];
    self.myImageView.image = dealedImage;

}

#pragma mark 将滤镜加在FilterGroup中并且设置初始滤镜和末尾滤镜
- (void)addGPUImageFilter:(GPUImageFilter *)filter{
    
    [self.myFilterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = self.myFilterGroup.filterCount;
    
    if (count == 1)
    {
        //设置初始滤镜
        self.myFilterGroup.initialFilters = @[newTerminalFilter];
        //设置末尾滤镜
        self.myFilterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = self.myFilterGroup.terminalFilter;
        NSArray *initialFilters                          = self.myFilterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        //设置初始滤镜
        self.myFilterGroup.initialFilters = @[initialFilters[0]];
        //设置末尾滤镜
        self.myFilterGroup.terminalFilter = newTerminalFilter;
    }
}

@end
