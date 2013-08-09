//
//  SoundData.h
//  DashBoard
//
//  Created by Yong Yang on 13-8-5.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundData : NSObject
{
    NSMutableDictionary *dashBoardFolders, *mySounds;
}

+ (SoundData *)sharedSoundData;

- (void)storageSoundDataByFolderName:(NSString *)folderName andSoundName:(NSString *)soundName andAudioRecorder:(AVAudioRecorder *)recorder;

- (AVAudioRecorder *)getRecorderBySoundName:(NSString *)soundName;


@end
