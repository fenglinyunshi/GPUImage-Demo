//
//  UIButton+Custom.h
//  解决多次点击相同的button
//
//  Created by Dustin on 16/11/17.
//  Copyright © 2016年 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)

@property (nonatomic, assign) NSTimeInterval custom_acceptEventInterval;// 可以用这个给重复点击加间隔
@property (nonatomic,strong) void (^callBack)();//在不响应时可以提示用户点击过于频繁等操作

@end
