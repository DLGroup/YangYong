//
//  DLRecorder.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 1/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "DLRecorder.h"
#import "GlobalObj.h"
#import <sys/time.h>

///////////////////////////

static NSString* defaultName()
{
	struct timeval time;
    gettimeofday(&time, NULL);
    
    NSString *dateString=[NSString stringWithFormat:@"_%ld%d", time.tv_sec, time.tv_usec];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
    
	NSString* name=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:dateString];
    
	return [name stringByAppendingString:@".aif"];
}

static void AQInputCallback(void *aqData,
                            AudioQueueRef inAQ,
                            AudioQueueBufferRef inBuffer,
                            const AudioTimeStamp *inStartTime,
                            UInt32 inNumPackets,
                            const AudioStreamPacketDescription *inPacketDesc){
    struct _recorder_context *context = (struct _recorder_context*) aqData;
    
    if (inNumPackets == 0 && context->asbd.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / context->asbd.mBytesPerPacket;
    
    if (AudioFileWritePackets(context->file.fd, NO, inBuffer->mAudioDataByteSize, inPacketDesc, context->file.packetIdx, &inNumPackets, inBuffer->mAudioData) == noErr)
    {
        context->file.packetIdx += inNumPackets;
        if (context->state != RECORDING) return;
        AudioQueueEnqueueBuffer (context->queue, inBuffer, 0, NULL);
    }

}


static int ComputeRecordBufferSize(const AudioStreamBasicDescription *format,
                                   AudioQueueRef queue,
                                   float seconds){
    int packets, frames, bytes;
    frames = (int)ceil(seconds * format->mSampleRate);
    
    if (format->mBytesPerFrame > 0)
        bytes = frames * format->mBytesPerFrame;
    else
    {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0)
            
            // Constant packet size
            maxPacketSize = format->mBytesPerPacket;
        else
        {
            // Get the largest single packet size possible
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioQueueGetProperty(queue,
                                  kAudioConverterPropertyMaximumOutputPacketSize,
                                  &maxPacketSize,
                                  &propertySize);
        }
        if (format->mFramesPerPacket > 0)
            packets = frames / format->mFramesPerPacket;
        // Worst-case scenario: 1 frame in a packet
        else
            packets = frames;
        // Sanity check
        if (packets == 0)
            packets = 1;
        
        bytes = packets * maxPacketSize;
        
    }
    return bytes;
}

static OSStatus createNewAudioFile(struct _recorder_context *context){
    
    // create audio file
    NSString *path = [AUDIO_FOLDER stringByAppendingPathComponent:defaultName()];
    
    memcpy(context->file.path, [path UTF8String], path.length);

    CFURLRef fileURL =  CFURLCreateFromFileSystemRepresentation(NULL,
                                                                (const UInt8 *)[path UTF8String],
                                                                [path length],
                                                                NO);
    OSStatus status = AudioFileCreateWithURL(fileURL,
                                             kAudioFileAIFFType,
                                             &context->asbd,
                                             kAudioFileFlags_EraseFile,
                                             &context->file.fd);
    if(status != noErr){
        NSLog(@"create audio file error");
        CFRelease(fileURL);
        return status;
    }
    context->file.packetIdx=0;
    CFRelease(fileURL);
    
    return status;
}



            
static BOOL initRecorderContext(struct _recorder_context *context){
    
    memset(context, 0, sizeof(struct _recorder_context));
    memset(&context->queue, 0, sizeof(context->queue));
    
    // set audio file format
    if([DLRecorder setDefaultAudioFormat:&context->asbd] != YES){
        NSLog(@"set audio format error");
        return NO;
    }
    
    
    UInt32 s=sizeof(context->asbd);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                           0,
                           NULL, &s, &context->asbd);
    
    
    // create audio queue
    OSStatus status = AudioQueueNewInput(&context->asbd,
                                         AQInputCallback,
                                         context,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopCommonModes,
                                         0,
                                         &context->queue);
    if(status != noErr){
        NSLog(@"create audio queue error");
        return NO;
    }
    
    // create audio file
    if(createNewAudioFile(context) != noErr)
        return NO;
    
    // create audio queue buffer
    int bufferByteSize = ComputeRecordBufferSize(&context->asbd, context->queue, 0.5);
    
    context->bufSize = bufferByteSize;
    for(int idx = 0; idx < NUM_BUF; ++idx){
        
        status = AudioQueueAllocateBuffer(context->queue, bufferByteSize, &context->bufs[idx]);
        if(status != noErr){
            NSLog(@"alloc audio queue buffer error");
            return NO;
        }
        
        status = AudioQueueEnqueueBuffer(context->queue, context->bufs[idx], 0, NULL);
        if(status != noErr){
            NSLog(@"enqueue audio queue buffer error");
            return NO;
        }
        
    }
    
    // enable metering
    UInt32 enableMetering = YES;
    status = AudioQueueSetProperty(context->queue,
                                   kAudioQueueProperty_EnableLevelMetering,
                                   &enableMetering,
                                   sizeof(enableMetering));
    if (status){
        NSLog(@"could not enable metering");
        return NO;
    }
    
    return YES;
}

@implementation DLRecorder
@synthesize timeCounter=_timeCounter;
@synthesize timer=_timer;

+ (bool)setDefaultAudioFormat:(AudioStreamBasicDescription *)asbd{
    asbd->mSampleRate = 8000;
    asbd->mFormatID = kAudioFormatLinearPCM;
    asbd->mFormatFlags = kLinearPCMFormatFlagIsBigEndian|kLinearPCMFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked;
    asbd->mChannelsPerFrame = 1;
    asbd->mBitsPerChannel = 16;
    asbd->mFramesPerPacket = 1;
    asbd->mBytesPerPacket = 2;
    asbd->mBytesPerFrame = 2;
    asbd->mReserved = 0;
    
    
    UInt32 propSize = sizeof(AudioStreamBasicDescription);
    OSStatus status = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                             0,
                                             NULL,
                                             &propSize,
                                             asbd);
    
    return (status == noErr ? YES : NO);

}


- (void)timerCallback{
    if(context.state==RECORDING){
        ++_timeCounter;
    }
}

- (id)init{
    self = [super init];
    if(self){
        if(!initRecorderContext(&context))
            return nil;
        
        context.state=INIT;
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];

    }
    return self;
}


- (BOOL)start{
    
    // first start
    if(context.state == INIT){
        if(AudioQueueStart(context.queue, NULL)){
            NSLog(@"start audio queue error");
            return NO;
        }
    }
    
    // start agin after stop
    else if(context.state == STOP){
        OSStatus status;
        for(int idx = 0; idx < NUM_BUF; ++idx){
            status = AudioQueueEnqueueBuffer(context.queue, context.bufs[idx], 0, NULL);
            if(status != noErr){
                NSLog(@"enqueue audio queue buffer error");
                return NO;
            }
            
        }
        createNewAudioFile(&context);
        if(AudioQueueStart(context.queue, NULL)){
            NSLog(@"could not start audio queue");
            return NO;
        }
    }
    
    else{
        return NO;
    }
    
    context.state=RECORDING;
    
    return YES;
}


- (void)estimateSize{
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus status = AudioFileGetProperty(context.file.fd,
                                           kAudioFilePropertyAudioDataByteCount,
                                           &thePropSize,
                                           &context.size);
    if(status != 0){
        NSLog(@"get audio file size error");
        context.size=0;
    }
}

- (void)estimateDuration{
	
	UInt32 propSize=0;
	UInt32 isWritable;
	OSStatus status;
	status = AudioFileGetPropertyInfo(context.file.fd,
                                      kAudioFilePropertyEstimatedDuration,
                                      &propSize,
                                      &isWritable);
	if(status != noErr){
        NSLog(@"get audio file duration error");
        context.duration = 0.0;
        return;
    }
	
	status = AudioFileGetProperty(context.file.fd,
                                  kAudioFilePropertyEstimatedDuration,
                                  &propSize,
                                  &context.duration);
	if(status != noErr){
        NSLog(@"get audio file property error");
        context.duration = 0.0;
        return;
    }
    
}

- (void)drop{
    [self stop];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[self filePath] error:nil];
}

- (void)stop{
    AudioQueueFlush(context.queue);
    AudioQueueStop(context.queue, YES);
    
    [self estimateDuration];
    [self estimateSize];
    AudioFileClose(context.file.fd);
    
    context.state=STOP;
    _timeCounter=0;
}

- (void)pause{
    if(AudioQueuePause(context.queue)){
        NSLog(@"could not pause audio queue");
    }
    
    context.state=PAUSE;
}

- (void)resume{
    if(AudioQueueStart(context.queue, NULL)){
        NSLog(@"could not start audio queue");
    }
    
    context.state=RECORDING;
}

- (void)exit{
    AudioQueueFlush(context.queue);
    AudioQueueStop(context.queue, YES);
    
    for(int idx = 0; idx < NUM_BUF; idx++)
		AudioQueueFreeBuffer(context.queue, context.bufs[idx]);
    
    AudioQueueDispose(context.queue, YES);
    AudioFileClose(context.file.fd);
}

- (float)averagePower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(context.queue,
                                   kAudioQueueProperty_CurrentLevelMeter,
                                   &state,
                                   &statesize);
    if (status){
        NSLog(@"get retrieving average meter error");
        return 0.0f;
    }
    return state[0].mAveragePower;
}

- (float)peakPower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(context.queue,
                                   kAudioQueueProperty_CurrentLevelMeter,
                                   &state,
                                   &statesize);
    if (status) {
        NSLog(@"get retrieving peak meter error");
        return 0.0f;
    }
    return state[0].mPeakPower;
}

- (NSString*)filePath{
    return [NSString stringWithUTF8String:context.file.path];
}

- (double)duration{
    return context.duration;
}
- (UInt64)size{
    return context.size;
}

- (enum RECORDER_STATE)state{
    return context.state;
}
@end








