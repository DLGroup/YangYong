//
//  DLPlayer.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 1/28/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define NUM_BUF 3

enum PLAYER_STATE{
    PLAYER_INIT,
    PLAYER_PLAYING,
    PLAYER_PAUSE,
    PLAYER_STOP,
};

struct _player_file{
    AudioFileID                 fd;
    SInt64                      packetIdx;
    
};

struct _player_context{
    AudioQueueRef               queue;
    AudioQueueBufferRef         bufs[NUM_BUF];
    AudioStreamBasicDescription asbd;
    
    UInt32                      bufSize;
    UInt32                      numPacketsInBuf;
	AudioStreamPacketDescription *packetDescs;
	
	SInt64 startPacketIdx;
	SInt64 endPacketIdx;
    SInt64 numTotalPacket;
    
    double duration;
    bool status;
    
    struct _player_file file;
};



@interface DLPlayer : NSObject{
    struct _player_context context;
    NSString *path;
    
    NSMutableArray *samples;
    BOOL isCalculateSamples;
    enum PLAYER_STATE state;
    
    float durationBase;
}

@property (strong, nonatomic) NSMutableArray *samples;
@property (assign, nonatomic) BOOL isCalculateSamples;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) enum PLAYER_STATE state;
@property (strong, nonatomic) NSTimer *timer;

- (id)initWithAudioFileURL:(NSString*)filePath;
- (void)estimateDuration;
- (void)play;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)setStartPostion:(float)firstPosition endPoint:(float)secondPostion;
- (double)estimateProgress;
- (void)setProgressWithFloat:(float)value;
- (bool)status;
- (double)duration;
- (void)caculateSamples:(NSBlockOperation*)operation;
- (enum PLAYER_STATE)state;
- (void)createSegmentAudio:(float)firstPosition endPoint:(float)secondPosition withReplace:(bool)replace;
- (void)reset;
- (BOOL)isStop;
@end

















