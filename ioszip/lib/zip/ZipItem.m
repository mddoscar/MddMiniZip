//
//  ZipItem.m
//  Zip_demo_2015_5_29
//
//  Created by 月光 on 15/6/2.
//  Copyright (c) 2015年 月光. All rights reserved.
//

#import "ZipItem.h"


@implementation ZipItem

-(id) initWithDataPath:(NSString *)pFullPath mShortFileName:(NSString *)pShortFileName
{
    if (self=[super init]) {
        self.mFullPath=pFullPath;
        self.mShortFileName=pShortFileName;
    }
    return  self;
}

@end
