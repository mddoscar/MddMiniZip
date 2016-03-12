//
//  MyZipHelper.m
//  Zip_demo_2015_5_29
//
//  Created by 月光 on 15/5/29.
//  Copyright (c) 2015年 月光. All rights reserved.
//

#import "MyZipHelper.h"

#import "ZipItem.h"
//字典项
//#define kPath @"Path"
//#define kFileName @"ShortFileName"

/*
 in the arc of ios 8 or laster ,at arc mode some function has been
 out date, and  here syntex error
 */
@interface MyZipHelper (Private)
//错误信息
-(void) sendErrorMessage:(NSString*) pMessage;
//覆盖操作
-(BOOL) doOverWriteOperation:(NSString*) pFile;
//日期1980
-(NSDate*) Date1980;
@end


@implementation MyZipHelper
//绑定
@synthesize mDelegate = _mDelegate;
#pragma  mark 初始化相关
//初始化
-(id) init
{
    if(self=[super init])
    {
        _mZipFile = NULL ;
    }
    return self;
}
-(void) dealloc
{
    [self closeZipFile];
}

-(BOOL) zipWithFile:(NSString*) pZipFile
{
    BOOL result=YES;
    _mZipFile = zipOpen( (const char*)[pZipFile UTF8String], 0 );
    if( !_mZipFile )
    {
        result= NO;
    }
    return result;
}

-(BOOL) zipWithFile:(NSString*) pZipFile Password:(NSString*) pPassword;
{
    _mPassword = pPassword;
    return [self zipWithFile:pZipFile];
}

-(BOOL) addFileToZip:(NSString*) pFile newname:(NSString*) pNewname
{
    if( !_mZipFile )
        return NO;
    time_t current;
    time(&current);
    
    zip_fileinfo zipInfo = {0};
    
    NSError * error;
    NSDictionary* attr =[[NSFileManager defaultManager]attributesOfItemAtPath:pFile  error:&error];//
    if (nil!=error) {
        NSLog(@"%@",error);
    }
    //如果有文件
    if( attr )
    {
        //修改日期
        NSDate* fileDate = (NSDate*)[attr objectForKey:NSFileModificationDate];
        if( fileDate )
        {
            NSCalendar* currCalendar = [NSCalendar currentCalendar];
            uint flags =NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay|
            NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
            NSDateComponents* dc = [currCalendar components:flags fromDate:fileDate];
            zipInfo.tmz_date.tm_sec = (uInt)[dc second];
            zipInfo.tmz_date.tm_min = (uInt)[dc minute];
            zipInfo.tmz_date.tm_hour = (uInt)[dc hour];
            zipInfo.tmz_date.tm_mday =(uInt) [dc day];
            zipInfo.tmz_date.tm_mon = (uInt)[dc month] - 1;
            zipInfo.tmz_date.tm_year = (uInt)[dc year];
        }
    }
    //
    long ret ;
    NSData* data = nil;
    if( [_mPassword length] <= 0 )
    {
        //新建压缩文件
        ret = zipOpenNewFileInZip( _mZipFile,
                                  (const char*) [pNewname UTF8String],
                                  &zipInfo,
                                  NULL,0,
                                  NULL,0,
                                  NULL,//comment
                                  Z_DEFLATED,
                                  Z_DEFAULT_COMPRESSION );
    }
    else
    {
        //获取数据
        data = [ NSData dataWithContentsOfFile:pFile];
        uLong crcValue = crc32( 0L,NULL, 0L );
        crcValue =crc32( crcValue, (const Bytef*)[data bytes], (uInt)[data length] );
        //新建文件
        ret = zipOpenNewFileInZip3( _mZipFile,
                                   (const char*) [pNewname UTF8String],
                                   &zipInfo,
                                   NULL,0,
                                   NULL,0,
                                   NULL,//comment
                                   Z_DEFLATED,
                                   Z_DEFAULT_COMPRESSION,
                                   0,
                                   15,
                                   8,
                                   Z_DEFAULT_STRATEGY,
                                   [_mPassword cStringUsingEncoding:NSASCIIStringEncoding],
                                   crcValue );
    }
    if( ret!=Z_OK )
    {
        return NO;
    }
    if( data==nil )
    {
        data = [ NSData dataWithContentsOfFile:pFile];
    }
    //文件大小
    unsigned int dataLen = (unsigned int)[data length];
    ret = zipWriteInFileInZip( _mZipFile, (const void*)[data bytes], dataLen);
    if( ret!=Z_OK )
    {
        return NO;
    }
    //关闭
    ret = zipCloseFileInZip( _mZipFile );
    if( ret!=Z_OK )
    {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL) closeZipFile
{
    _mPassword = nil;
    if( _mZipFile==NULL )
    {
        return NO;
    }
    BOOL ret =  zipClose( _mZipFile,NULL )==Z_OK?YES:NO;
    _mZipFile = NULL;
    return ret;
}

-(BOOL) UnzipFromFile:(NSString*) pZipFile
{
    _mUnzFile = unzOpen( (const char*)[pZipFile UTF8String] );
    if( _mUnzFile )
    {
        unz_global_info  globalInfo = {0};
        if( unzGetGlobalInfo(_mUnzFile, &globalInfo )==UNZ_OK )
        {
            NSLog(@"%@",[NSString stringWithFormat:@"%ld entries in the zip file",globalInfo.number_entry] );
            
            
        }
    }
    return _mUnzFile!=NULL;
}

-(BOOL) UnzipFromFile:(NSString*) pZipFile Password:(NSString*) pPassword
{
    _mPassword = pPassword;
    return [self UnzipFromFile:pZipFile];
}

-(BOOL) UnzipFileTo:(NSString*) pPath overWrite:(BOOL) pOverwrite
{
    BOOL success = YES;
    int ret = unzGoToFirstFile( _mUnzFile );
    unsigned char		buffer[4096] = {0};
    NSFileManager* fman = [NSFileManager defaultManager];
    if( ret!=UNZ_OK )
    {
        [self sendErrorMessage:@"Failed"];
    }
    
    do{
        if( [_mPassword length]==0 )
            ret = unzOpenCurrentFile( _mUnzFile );
        else
            ret = unzOpenCurrentFilePassword( _mUnzFile, [_mPassword cStringUsingEncoding:NSASCIIStringEncoding] );
        if( ret!=UNZ_OK )
        {
            [self OutputErrorMessage:@"Error occurs"];
            success = NO;
            break;
        }
        // reading data and write to file
        int read ;
        unz_file_info	fileInfo ={0};
        ret = unzGetCurrentFileInfo(_mUnzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
        if( ret!=UNZ_OK )
        {
            [self OutputErrorMessage:@"Error occurs while getting file info"];
            success = NO;
            unzCloseCurrentFile( _mUnzFile );
            break;
        }
        char* filename = (char*) malloc( fileInfo.size_filename +1 );
        unzGetCurrentFileInfo(_mUnzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
        filename[fileInfo.size_filename] = '\0';
        
        // check if it contains directory
        NSString * strPath =[NSString stringWithUTF8String:filename];//[NSString  stringWithCString:filename];
        BOOL isDirectory = NO;
        if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
            isDirectory = YES;
        free( filename );
        if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
        {// contains a path
            strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        }
        NSString* fullPath = [pPath stringByAppendingPathComponent:strPath];
        
        if( isDirectory )
            [fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        else
            [fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        if( [fman fileExistsAtPath:fullPath] && !isDirectory && !pOverwrite )
        {
            if( ![self OverWrite:fullPath] )
            {
                unzCloseCurrentFile( _mUnzFile );
                ret = unzGoToNextFile( _mUnzFile );
                continue;
            }
        }
        FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
        while( fp )
        {
            read=unzReadCurrentFile(_mUnzFile, buffer, 4096);
            if( read > 0 )
            {
                fwrite(buffer, read, 1, fp );
            }
            else if( read<0 )
            {
                [self OutputErrorMessage:@"Failed to reading zip file"];
                break;
            }
            else
                break;
        }
        if( fp )
        {
            fclose( fp );
            // set the orignal datetime property
            NSDate* orgDate = nil;
            
            //{{ thanks to brad.eaton for the solution
            NSDateComponents *dc = [[NSDateComponents alloc] init];
            
            dc.second = fileInfo.tmu_date.tm_sec;
            dc.minute = fileInfo.tmu_date.tm_min;
            dc.hour = fileInfo.tmu_date.tm_hour;
            dc.day = fileInfo.tmu_date.tm_mday;
            dc.month = fileInfo.tmu_date.tm_mon+1;
            dc.year = fileInfo.tmu_date.tm_year;
            
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            orgDate = [gregorian dateFromComponents:dc] ;
            //			[dc release];
            //			[gregorian release];
            //}}
            
            
            NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
            if( attr )
            {
                //		[attr  setValue:orgDate forKey:NSFileCreationDate];
                if( ![[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPath error:nil] )
                {
                    // cann't set attributes
                    NSLog(@"Failed to set attributes");
                }
                
            }
            
            
            
        }
        unzCloseCurrentFile( _mUnzFile );
        ret = unzGoToNextFile( _mUnzFile );
    }while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
    return success;
}

-(BOOL) UnzipCloseFile
{
    _mPassword = nil;
    if( _mUnzFile )
    {
        return unzClose( _mUnzFile )==UNZ_OK;
    }
    return YES;
}
#pragma mark wrapper for delegate
#pragma mark wrapper for delegate
-(void) OutputErrorMessage:(NSString*) pMsg
{
    if( _mDelegate && [_mDelegate respondsToSelector:@selector(sendErrorMessage:)] )
        [_mDelegate sendErrorMessage:pMsg];
}

-(BOOL) OverWrite:(NSString*) pFile
{
    if( _mDelegate && [_mDelegate respondsToSelector:@selector(doOverWriteOperation:)] )
        return [_mDelegate doOverWriteOperation:pFile];
    return YES;
}
#pragma mark get NSDate object for 1980-01-01
//1980日期型
-(NSDate*) Date1980
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:1980];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *result = [gregorian dateFromComponents:comps];
    return result;
}

#pragma  mark 压缩方法
+(BOOL)createZipToPath:(NSString *)pFullPath itemList:(NSArray *)pItemDicstionList
{
    BOOL result=false;
    MyZipHelper *tZip=[[[self class]alloc]init];
    @try {
        result = [tZip zipWithFile:pFullPath];
        for (ZipItem * obj in pItemDicstionList) {
            result = [tZip addFileToZip:[obj mFullPath] newname:[obj mShortFileName]];
        }
        if( ![tZip closeZipFile] )
        {
            pFullPath = @"";
        }

    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    return result;

}
+(void) createZipToPathCallBack:(NSString *) pFullPath itemList:(NSArray *)pItemDicstionList success:(void(^)(BOOL pResult)) pSuccessHandler error:(void(^)(NSException *pException))pErrorHandler
{
    BOOL result=false;
    MyZipHelper *tZip=[[[self class]alloc]init];
    @try {
        result = [tZip zipWithFile:pFullPath];
        for (ZipItem * obj in pItemDicstionList) {
            result = [tZip addFileToZip:[obj mFullPath] newname:[obj mShortFileName]];
        }
        if( ![tZip closeZipFile] )
        {
            pFullPath = @"";
        }
        
    }
    @catch (NSException *exception) {
        pErrorHandler(exception);
    }
    @finally {
        pSuccessHandler(result);
    }
}

+(BOOL) unZipfromPath:(NSString *) pFullPath toPath:(NSString *)pPath
{
    BOOL result=false;
    MyZipHelper *tZip=[[[self class]alloc]init];
    @try {
        if( [tZip UnzipFromFile:pFullPath] )
        {
            result = [tZip UnzipFileTo:pPath overWrite:YES];
            if( NO==result )
            {
            }
            result=[tZip UnzipCloseFile];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    return result;
}

+(void) unZipfromPathCallBack:(NSString *) pFullPath toPath:(NSString *)pPath  success:(void(^)(BOOL pResult)) pSuccessHandler error:(void(^)(NSException *pException))pErrorHandler
{
    BOOL result=false;
    MyZipHelper *tZip=[[[self class]alloc]init];
    @try {
        if( [tZip UnzipFromFile:pFullPath] )
        {
            result = [tZip UnzipFileTo:pPath overWrite:YES];
            if( NO==result )
            {
            }
            result=[tZip UnzipCloseFile];
        }
    }
    @catch (NSException *exception) {
        pErrorHandler(exception);
    }
    @finally {
        pSuccessHandler(result);
    }
}
/*
 -(void) toZip1
 {
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 //    NSString* l_zipfile = [documentpath stringByAppendingString:@"/test.zip"] ;
 NSMutableArray * array=[NSMutableArray array];
 [array addObject:[[ZipItem alloc]initWithDataPath:[documentpath stringByAppendingString:@"/World.smwu"] mShortFileName:@"World.smwu"] ];
 [array addObject:[[ZipItem alloc]initWithDataPath:[documentpath stringByAppendingString:@"/World.udb"] mShortFileName:@"World.udb"] ];
 [array addObject:[[ZipItem alloc]initWithDataPath:[documentpath stringByAppendingString:@"/World.udd"] mShortFileName:@"World.udd"] ];
 //[MyZipHelper createZipToPath:[documentpath stringByAppendingString:@"/test.zip"] itemList:array];
 [MyZipHelper createZipToPathCallBack:[documentpath stringByAppendingString:@"/test.zip"] itemList:array success:^(BOOL pResult) {
 NSLog(@"回调结果,%@",pResult?@"y":@"n");
 } error:^(NSException *pException) {
 NSLog(@"回调异常%@",pException);
 }];
 
 //    array addObject:
 
 }
 -(void) fromZip1
 {
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
 //    [MyZipHelper unZipfromPath:[documentpath stringByAppendingString:@"/test.zip"] toPath:[documentpath stringByAppendingString:@"/test"]];
 [MyZipHelper unZipfromPathCallBack:[documentpath stringByAppendingString:@"/test.zip"] toPath:[documentpath stringByAppendingString:@"/test"] success:^(BOOL pResult) {
 NSLog(@"回调结果,%@",pResult?@"y":@"n");
 } error:^(NSException *pException) {
 NSLog(@"回调异常%@",pException);
 }];
 }
*/
@end
