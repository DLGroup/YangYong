//
//  SoundData.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-5.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

//need to permanent later

#import "SoundData.h"

@implementation SoundData

- (id)init
{
    NSAssert(NO, @"Cannot create instance of Singleton");
    return nil;
}
- (id)initSoundData
{
    self = [super init];
    if (self == [super init]) {
        //init the property
        mySounds = [[NSMutableDictionary alloc] init];
        dashBoardFolders = [[NSMutableDictionary alloc] init];
    }
    return self;
}
+ (SoundData *)sharedSoundData
{
    static SoundData *soundData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundData = [[self alloc] initSoundData];
    });
    return soundData;
}

- (void)storageSoundDataByFolderName:(NSString *)folderName andSoundName:(NSString *)soundName andAudioRecorder:(AVAudioRecorder *)recorder
{
    static BOOL isInserting = TRUE;
    for (NSString *name in [mySounds allKeys]) {
        if ([folderName isEqualToString:name]) {
            isInserting = FALSE;
        }
    }
    if (isInserting) {
        [mySounds setObject:recorder forKey:soundName];
        [dashBoardFolders setObject:mySounds forKey:folderName];
    }
}

- (AVAudioRecorder *)getRecorderBySoundName:(NSString *)soundName
{
    return [mySounds objectForKey:soundName];
}


@end
