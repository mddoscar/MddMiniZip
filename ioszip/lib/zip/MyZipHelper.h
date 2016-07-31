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
/*
 举个栗子
 -(void) doTestUnzip
 {
 NSString * tFile=@"Test.zip";
 //copy
 BOOL suc= [gFileHelper CopyDirectory:[gFileHelper dirResource:tFile] desdir:[gFileHelper dirDoc:[ServerForResource relationPathDocForDownLoadFileName:tFile mUserPath:kDefUser]] fileManager:[NSFileManager defaultManager]];
 NSLog(@"%@",suc?@"Y":@"N");
 NSString * saveName=[ServerForResource relationPathDocForDownLoadFileName:tFile mUserPath:kDefUser];//[gFileHelper converPathToShortName:self.mParmDic[kPath]];
 NSString * savePath=[gFileHelper dirDoc:saveName];
 NSString *unZipPath=[gFileHelper dirDoc:[ServerForResource relationPathDocForLocalUnzipUserPath:kDefUser]];
 
 //[dataService doCopyResource];
 [MyZipHelper unZipfromPathCallBack:savePath toPath:unZipPath success:^(BOOL pResult) {
 //        MyButtonItem *cancelButtonItem = [[MyButtonItem alloc] initWithTitleCallBack:@"确定" mCallBack:^{
 //            [gFileHelper deleteFileWithFullPath:savePath];
 //            //隐藏按钮
 ////            [self setButtonState:NO];
 //        }];
 //        UIAlertView * dlg=[[UIAlertView alloc]initWithTitle:@"解压回调结果" message:[NSString stringWithFormat:@"%@",pResult?@"成功":@"失败"] cancelButtonItem:cancelButtonItem otherButtonItems:nil, nil];
 //        [dlg show];
 NSLog(@"成功？%@",pResult?@"Y":@"N");
 [gFileHelper deleteFileWithFullPath:savePath];
 
 //NSLog(@"解压回调结果,%@",pResult?@"y":@"n");
 } error:^(NSException *pException) {
 NSLog(@"回调异常%@",pException);
 }];
 
 }

 */
@end
