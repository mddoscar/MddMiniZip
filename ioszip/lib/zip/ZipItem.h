//
//  ZipItem.h
//  Zip_demo_2015_5_29
//
//  Created by 月光 on 15/6/2.
//  Copyright (c) 2015年 月光. All rights reserved.
//

#import <Foundation/Foundation.h>

//子项
@interface ZipItem : NSObject

#pragma  mark 成员变量
//文件路径
@property (strong ,nonatomic) NSString * mFullPath;
//文件名称
@property (strong,nonatomic) NSString * mShortFileName;

#pragma  mark 初始化
-(id) initWithDataPath:(NSString *) pFullPath mShortFileName:(NSString *)pShortFileName;


@end
