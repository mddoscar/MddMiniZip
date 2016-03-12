//
//  MyZipHelper.h
//  Zip_demo_2015_5_29
//
//  Created by 月光 on 15/5/29.
//  Copyright (c) 2015年 月光. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
//底层类库
#include "zip.h"
#include "unzip.h"
//#include "minizip/zip.h"
//#include "minizip/unzip.h"
//z类库
#import "zlib.h"
#import "zconf.h"

/**
 需要引用类库libz
 */

#pragma  mark 协议部分
@protocol MyZipDelegate <NSObject>
@optional
//错误信息
-(void) sendErrorMessage:(NSString*) pMessage;
//覆盖操作
-(BOOL) doOverWriteOperation:(NSString*) pFile;

@end

@interface MyZipHelper : NSObject
{
@private
    //压缩文件
    zipFile		_mZipFile;
    //解压文件
    unzFile		_mUnzFile;
    //密码
    NSString*   _mPassword;
    //代理
    id			_mDelegate;
}
//托管
@property (nonatomic, retain) id mDelegate;
#pragma  mark 基础方法
#pragma mark 压缩
//创建压缩
-(BOOL) zipWithFile:(NSString*) pZipFile;
//带密码
-(BOOL) zipWithFile:(NSString*) pZipFile Password:(NSString*) pPassword;
//添加文件
-(BOOL) addFileToZip:(NSString*) pFile newname:(NSString*) pNewname;
//关闭压缩
-(BOOL) closeZipFile;
#pragma  mark 解压
//解压
-(BOOL) UnzipFromFile:(NSString*) pZipFile;
//带密码解压
-(BOOL) UnzipFromFile:(NSString*) pZipFile Password:(NSString*) pPassword;
//解压到
-(BOOL) UnzipFileTo:(NSString*) pPath overWrite:(BOOL) pOverwrite;
//关闭
-(BOOL) UnzipCloseFile;

#pragma mark 调用
//将文件添加到全路径.zip (Path,ShortFileName)
+(BOOL) createZipToPath:(NSString *) pFullPath itemList:(NSArray *)pItemDicstionList;
+(void) createZipToPathCallBack:(NSString *) pFullPath itemList:(NSArray *)pItemDicstionList success:(void(^)(BOOL pResult)) pSuccessHandler error:(void(^)(NSException *pException))pErrorHandler;
//将文件解压出来
+(BOOL) unZipfromPath:(NSString *) pFullPath toPath:(NSString *)pPath;
//从长长的完整路径（.../.../test.zip）到，文件夹相对路径（/test）
+(void) unZipfromPathCallBack:(NSString *) pFullPath toPath:(NSString *)pPath  success:(void(^)(BOOL pResult)) pSuccessHandler error:(void(^)(NSException *pException))pErrorHandler;

@end
