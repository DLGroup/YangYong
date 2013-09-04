//
//  DLRecorder.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 1/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define NUM_BUF 3
#define AUDIO_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Audios"]

enum RECORDER_STATE{
    INIT,
    RECORDING,
    PAUSE,
    STOP,
};

struct _recorder_file{
    AudioFileID                 fd;
    SInt64                      packetIdx;
    char                        path[1024];
};

struct _recorder_context{
    AudioQueueRef               queue;
    AudioQueueBufferRef         bufs[NUM_BUF];
    UInt32                      bufSize;
    AudioStreamBasicDescription asbd;
    enum RECORDER_STATE         state;
    
    struct _recorder_file file;
    
    double duration;
    UInt64 size;
};



@interface DLRecorder : NSObject{
    struct _recorder_context context;
}

@property (assign, nonatomic)int timeCounter;
@property (strong, nonatomic)NSTimer *timer;
- (id)init;
- (BOOL)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)exit;
- (void)drop;

- (double)duration;
- (enum RECORDER_STATE)state;
- (UInt64)size;
- (float)averagePower;
- (float)peakPower;
- (NSString*)filePath;
+ (bool)setDefaultAudioFormat:(AudioStreamBasicDescription*)asbd;
@end





