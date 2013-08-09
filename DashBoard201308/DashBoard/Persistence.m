//
//  Persistence.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-6.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//


//maybe will have problem method
//- (void)addRecord:(RecordInfo *)record toFolder:(NSString *)folderName

#import "Persistence.h"
#import "RecordInfo.h"

#define FOLDERSNAME @"folders.plist"

@implementation Persistence

#pragma mark - Singleton method

- (id)init
{
    NSAssert(NO, @"Cannot create instance of a singleton class this way!");
    return nil;
}

- (id)initPersistence
{
    if (self = [super init]) {
        //create a plist file
        NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:FOLDERSNAME];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if (![defaultManager fileExistsAtPath:filePath]) {
            [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
            folders = [[NSMutableDictionary alloc] init];
            recorders = [[NSMutableDictionary alloc] init];
        }
        else
        {
            folders = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        }
    }
    return self;
}

+ (Persistence *)sharedPersistence
{
    static Persistence *persistence = nil;
    //the singleton mode need to know why
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistence = [[self alloc] initPersistence];
    });
    return persistence;
}

#pragma mark - Folder operate

- (NSMutableDictionary *)getFoldersName
{
    return folders;
}

- (void)addFolder:(NSString *)folderName
{
    [folders setObject:[[NSMutableDictionary alloc] init] forKey:folderName];
    [self updateFile];
       
}

- (BOOL)removeFolder:(NSString *)folderName
{
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    recorders = [folders objectForKey:folderName];
    for (NSString *recordName in [recorders allKeys]) {
        NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:recordName];
        if (![defaultManager fileExistsAtPath:filePath])
        {
            [defaultManager removeItemAtPath:filePath error:nil];
        }        
        else
        {
            NSLog(@"the record infomation is not existed!");
            return NO;//delete not successfully！
        }
    }
    //remove the folder used by folderName
    [folders removeObjectForKey:folderName];
    [self updateFile];
    return YES;
}

#pragma mark - Record operate

- (void)addRecord:(RecordInfo *)record toFolder:(NSString *)folderName
{
    recorders = [folders objectForKey:folderName];
    // ---------------------------------------
    // archiver the data realized the NSCoding delegate
    NSMutableData *recordData = [[NSMutableData alloc] init];
    NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:recordData];
    [ar encodeObject:record forKey:@"kRecord"];
    [ar finishEncoding];
    // ----------------------------------------
    [recordData writeToFile:[[self dataFilePath] stringByAppendingPathComponent:[record recordName]] atomically:YES];
    [recorders setObject:recordData forKey:[record recordName]];
    [self updateFile];
}

- (BOOL)removeRecord:(NSString *)recordName from:(NSString *)folderName
{
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    //remove the file in the user's document 
    NSString *filePath = [[self dataFilePath] stringByAppendingPathComponent:recordName];
    if (![defaultManager fileExistsAtPath:filePath])
    {
        [defaultManager removeItemAtPath:filePath error:nil];
        filePath = nil;
    }
    else
    {
        NSLog(@"the record infomation is not existed!");
        return NO;//删除不成功！
    }
    //delete the record used by recordName
    [[folders objectForKey:folderName] removeObjectForKey:recordName];
    [self updateFile];
    return YES;
}

- (RecordInfo *)getRecordByFolderName:(NSString *)folderName andRecordName: (NSString *)recordName
{
    // --------------------------------------
    // unarchiver the data to recordInfo
    NSMutableData *record = [[NSMutableData alloc] initWithContentsOfFile:[[self dataFilePath] stringByAppendingPathComponent:recordName]];
    RecordInfo *recordInfo=[[RecordInfo alloc] init];
    NSKeyedUnarchiver *uar = [[NSKeyedUnarchiver alloc] initForReadingWithData:record];
    recordInfo = [uar decodeObjectForKey:@"kRecord"];
    [uar finishDecoding];
    // --------------------------------------
    return recordInfo;
}

- (NSMutableDictionary *)getRecordsByFolderName: (NSString *)folderName
{
    return [folders objectForKey:folderName];
}

#pragma mark - Inner method

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (void)updateFile
{
    //update the plist file
    if(![folders writeToFile:[[self dataFilePath] stringByAppendingPathComponent:FOLDERSNAME] atomically:YES])
         NSLog(@"some problem happened while write data to folders.plist");
}

@end
