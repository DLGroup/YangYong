//
//  DLPlayer.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 1/28/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "DLPlayer.h"
#import "DLRecorder.h"

@implementation DLPlayer

@synthesize samples=_samples;
@synthesize isCalculateSamples=_isCalculateSamples;
@synthesize path=_path;
@synthesize state=_state;
@synthesize timer=_timer;

- (bool)status{
    return context.status;
}

- (double)estimateProgress{
    AudioTimeStamp timeStamp;
    OSStatus error=AudioQueueGetCurrentTime(context.queue, NULL, &timeStamp, NULL);
    
    double progress=timeStamp.mSampleTime/8000.0f/context.duration;
    if(error){
        NSLog(@"%ld", error);
        return 1.0f;
    }
    
    else
        return progress+durationBase;
    //return  (double)context.file.packetIdx/(double)context.numTotalPacket;
}

- (void)setProgressWithFloat:(float)value{
    
    durationBase=value;
    float startTime = value*context.duration;
    
    SInt64 startPacket=context.asbd.mSampleRate * startTime ;
	startPacket /= context.asbd.mFramesPerPacket;
    
    context.file.packetIdx=startPacket;
    
    AudioQueueStop(context.queue, true);
    
    context.status=NO;

    // enqueue buffer
	for(int idx=0; idx<NUM_BUF; ++idx)
		AQOutputCallback(&context, context.queue, context.bufs[idx]);
    
    AudioQueueStart(context.queue, NULL);
    
   // _state=PLAYER_PLAYING;
    [self checkPlayState];
    
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
        NSLog(@"get audio file property info error");
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

static void AQOutputCallback(void *inUserData,
                             AudioQueueRef inAQ,
                             AudioQueueBufferRef inCompleteAQBuffer){
    
	struct _player_context *context = (struct _player_context*)inUserData;
	if (context->status)
        return;
	
	// Reading Packets from Audio File
	UInt32 numBytes;
	UInt32 nPackets = context->numPacketsInBuf;
	
    if(context->endPacketIdx>0){
        if(context->endPacketIdx-context->file.packetIdx<nPackets)
            nPackets=context->endPacketIdx-context->file.packetIdx;
    }
    
    OSStatus status;
	status = AudioFileReadPackets(context->file.fd,
                                  false,
                                  &numBytes,
                                  context->packetDescs,
                                  context->file.packetIdx,
                                  &nPackets,
                                  inCompleteAQBuffer->mAudioData);
	if(status != noErr){
        NSLog(@"read audio file error");
        return;
    }
    
    // Enqueing Packets for Playback
	if (nPackets>0){
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;
		
		AudioQueueEnqueueBuffer(inAQ,
								inCompleteAQBuffer,
								(context->packetDescs ? nPackets : 0),
								context->packetDescs);
		
		context->file.packetIdx += nPackets;
		if (context->endPacketIdx > 0 && context->file.packetIdx > context->endPacketIdx)
			context->status=true;
	}
	else {
		
		// Stopping Audio Queue Upon Reaching End of File
		status = AudioQueueStop(inAQ, false);
        if(status != noErr){
            NSLog(@"stop audio queue error");
            return;
        }
		context->status=true;
		
	}
}


static void CalculateBytesForTime(AudioFileID inAudioFile,
                                  AudioStreamBasicDescription inDesc,
                                  Float64 inSeconds,
                                  UInt32 *outBufferSize,
                                  UInt32 *outNumPackets){
	UInt32 maxPacketSize;
	UInt32 propSize=sizeof(maxPacketSize);
	
	AudioFileGetProperty(inAudioFile,
                         kAudioFilePropertyPacketSizeUpperBound,
                         &propSize,
                         &maxPacketSize);
	
	static const int maxBufferSize= 0x10000;
	static const int minBufferSize = 0x4000;
	
    
	if (inDesc.mFramesPerPacket){
		
		// This means LPC (not variable rate)
		
		Float64 numPacketsForTime=inDesc.mSampleRate /
		inDesc.mFramesPerPacket * inSeconds;
		
		*outBufferSize=numPacketsForTime * maxPacketSize;
		
	}
	else {
		*outBufferSize=maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
	}
	
	if (*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
		*outBufferSize=maxBufferSize;
	else {
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / maxPacketSize;
}


- (void)createSegmentAudio:(float)firstPosition endPoint:(float)secondPosition withReplace:(bool)replace{
    
    SInt64 startPacketIdx=0, endPacketIdx;
    
    // get start and end packet index
	startPacketIdx=context.duration*context.asbd.mSampleRate * firstPosition ;
	startPacketIdx /= context.asbd.mFramesPerPacket;
	
    endPacketIdx=context.duration*context.asbd.mSampleRate * secondPosition;
	endPacketIdx /= context.asbd.mFramesPerPacket;
    
    
    // create audio file
    AudioStreamBasicDescription asbd;
    AudioFileID fd;
    [DLRecorder setDefaultAudioFormat:&asbd];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
    
	NSString* name=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
    
    NSString *tmpPath = [AUDIO_FOLDER stringByAppendingPathComponent:name];
    
    CFURLRef fileURL =  CFURLCreateFromFileSystemRepresentation(NULL,
                                                                (const UInt8 *)[tmpPath UTF8String],
                                                                [tmpPath length],
                                                                NO);
    OSStatus status = AudioFileCreateWithURL(fileURL,
                                             kAudioFileAIFFType,
                                             &asbd,
                                             kAudioFileFlags_EraseFile,
                                             &fd);
    if(status != noErr){
        NSLog(@"create audio file error");
        CFRelease(fileURL);
        return;
    }
    CFRelease(fileURL);
    
    UInt32 numBytes;
    SInt64 srcPacketIdx=startPacketIdx;
    SInt64 destPacketIdx=0;
    char *buf=malloc(context.bufSize);
    
    while(srcPacketIdx<endPacketIdx){
        
        UInt32 nPacketsRead = context.numPacketsInBuf;
        
        if(endPacketIdx-srcPacketIdx<nPacketsRead)
            nPacketsRead=endPacketIdx-srcPacketIdx;
        

        status = AudioFileReadPackets(context.file.fd,
                                      false,
                                      &numBytes,
                                      context.packetDescs,
                                      srcPacketIdx,
                                      &nPacketsRead,
                                      buf);
        
        if(status != noErr){
            NSLog(@"read audio file error");
            break;
        }
        
        if(nPacketsRead > 0){
            srcPacketIdx += nPacketsRead;
            
            UInt32 nPacketsWrite = nPacketsRead;
            status = AudioFileWritePackets(fd,
                                           false,
                                           numBytes,
                                           context.packetDescs,
                                           destPacketIdx,
                                           &nPacketsWrite,
                                           buf);
            if(status != noErr){
                NSLog(@"write audio file error");
                break;
            }
            
            if(nPacketsRead != nPacketsWrite)
                break;
            destPacketIdx += nPacketsWrite;
        }
        else
            break;
    }
    
    free(buf);
    AudioFileClose(fd);
    [self stop];

    //
    if(replace){
        
        //remove orign and set path
        NSFileManager *fm=[NSFileManager defaultManager];
        [fm removeItemAtPath:_path error:nil];
        [fm moveItemAtPath:tmpPath toPath:_path error:nil];
    }
}



- (void)caculateSamples:(NSBlockOperation*)operation{
    
    __weak DLPlayer *player=self;
    ExtAudioFileRef extAFRef;
    
    CFURLRef audioPath = (__bridge CFURLRef)[NSURL URLWithString:_path];
    OSStatus err = ExtAudioFileOpenURL(audioPath, &extAFRef);
    
    int bufSize=context.asbd.mSampleRate*sizeof(short);
    short *data=(short*)malloc(bufSize);
    
    AudioBufferList bufList;
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = 1;
    bufList.mBuffers[0].mData = data;
    bufList.mBuffers[0].mDataByteSize = bufSize;
    
    UInt32 readPackets=context.asbd.mSampleRate;
    
    if(!player.samples)
        player.samples=[[NSMutableArray alloc] init];
    else
        [player.samples removeAllObjects];
    
    short max=0;
    
    
    while(true){
        err = ExtAudioFileRead(extAFRef, &readPackets, &bufList);
        
        // file end
        if(readPackets == 0)
            break;
        
        for(int idx=0; idx<readPackets; ++idx){
            if([operation isCancelled]) break;
            [player.samples addObject:[NSNumber numberWithShort:data[idx]]];
            
            if(abs(data[idx]) > max)
                max=abs(data[idx]);
        }
    }
    
    //normalization
    for(int idx=0; idx<player.samples.count; ++idx){
        if([operation isCancelled]) break;
        short value=[[player.samples objectAtIndex:idx] shortValue];
        float normalizedValue=value/(float)max;
        
        [player.samples replaceObjectAtIndex:idx withObject:[NSNumber numberWithFloat:normalizedValue]];
    }
    
    
    
    free(data);
    err = ExtAudioFileDispose(extAFRef);
    
    player.isCalculateSamples=YES;
    
}


- (id)initWithAudioFileURL:(NSString*)filePath{
    self = [super init];
    if(!self)
        return nil;
    
    OSStatus status;
    _path=filePath;
    
    
    // open audio file
    NSURL *url = [NSURL fileURLWithPath:filePath];
    status = AudioFileOpenURL((__bridge CFURLRef)url,
                              kAudioFileReadPermission,
                              0,
                              &context.file.fd);
    
    if(status != noErr){
        NSLog(@"open audio file error");
        return nil;
    }
    
    // estimate duration
    [self estimateDuration];
    
    // get audio format
    UInt32 propSize=sizeof(AudioStreamBasicDescription);
	status = AudioFileGetProperty(context.file.fd,
                                  kAudioFilePropertyDataFormat,
                                  &propSize,
                                  &context.asbd);
    
    if(status != noErr){
        NSLog(@"get audio format error");
        return nil;
    }
    
    propSize=sizeof(SInt64);
	status = AudioFileGetProperty(context.file.fd,
                                  kAudioFilePropertyAudioDataPacketCount,
                                  &propSize,
                                  &context.numTotalPacket);
    
    // create audio queue
    AudioQueueNewOutput(&context.asbd,
                        AQOutputCallback,
                        &context,
                        NULL,
                        NULL,
                        0,
                        &context.queue);
    
    
    // compute buffer size and number of packet this buffer can include
    CalculateBytesForTime(context.file.fd,
						  context.asbd,
						  0.5,
						  &context.bufSize,
						  &context.numPacketsInBuf);
    
    
    // Allocation Memory for Packet Descriptions Array
	// VBR stands for Variable Bit Rate
	bool isFormatVBR=(context.asbd.mBytesPerPacket==0 || context.asbd.mFramesPerPacket==0);
	
	if (isFormatVBR)
		context.packetDescs=(AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * context.numPacketsInBuf);
	else
		context.packetDescs=NULL;
	
    
    context.startPacketIdx=0;
    context.endPacketIdx=-1;
    durationBase=0.0f;
    
    // create audio queue buffer
    for(int idx=0; idx<NUM_BUF; ++idx){
		status = AudioQueueAllocateBuffer(context.queue,
                                          context.bufSize,
                                          &context.bufs[idx]);
        if(status != noErr){
            NSLog(@"alloc audio queue buffer error");
            return nil;
        }
        
	}
    _state=PLAYER_INIT;
    return self;
}

- (void)reset{
    _state=PLAYER_INIT;
    context.file.packetIdx=0;
}

- (void)_check{
    UInt32 runing;
    UInt32 size=sizeof(UInt32);
    OSStatus error=AudioQueueGetProperty(context.queue,
                                         kAudioQueueProperty_IsRunning,
                                         &runing,
                                         &size);
    if(error){
        [_timer invalidate];
        _timer=nil;
    }
    
    if(runing){
        _state=PLAYER_PLAYING;
        [_timer invalidate];
        _timer=nil;
    }
}

- (void)checkPlayState{
    if(!_timer){
        _timer=[NSTimer  scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(_check) userInfo:nil repeats:YES];
    }
}

- (void)play{
	
    // set start point
	if (context.startPacketIdx)
		context.file.packetIdx=context.startPacketIdx;
	else
		context.file.packetIdx=0;
    
    context.status=NO;
    
    OSStatus status;
    
    AudioQueueStop(context.queue, true);
    
    // create buffer and enqueue it
	for(int idx=0; idx<NUM_BUF; ++idx){
		AQOutputCallback(&context, context.queue, context.bufs[idx]);
		
		if (context.status)
			break;
	}
	
	status = AudioQueueStart(context.queue, NULL);
	if(status != noErr){
        NSLog(@"start audio queue error");
        return;
    }
    
    //_state=PLAYER_PLAYING;
    [self checkPlayState];
}

- (void)stop{
    AudioQueueFlush(context.queue);
    AudioQueueStop(context.queue, YES);
    
    for(int idx = 0; idx < NUM_BUF; idx++)
		AudioQueueFreeBuffer(context.queue, context.bufs[idx]);
    
    if(context.packetDescs)
        free(context.packetDescs);
    
    AudioQueueDispose(context.queue, YES);
    AudioFileClose(context.file.fd);
    
    _state=PLAYER_STOP;
}

- (void)pause{
    AudioQueuePause(context.queue);
    _state=PLAYER_PAUSE;
}

- (void)resume{
    AudioQueueStart(context.queue, NULL);
    //_state=PLAYER_PLAYING;
    [self checkPlayState];
}

- (void)setStartPostion:(float)firstPosition endPoint:(float)secondPostion
{
    AudioQueueStop(context.queue, true);
    
	SInt64 startPacket=context.duration*context.asbd.mSampleRate * firstPosition ;
	startPacket /= context.asbd.mFramesPerPacket;
	
	SInt64 endPacket=context.duration*context.asbd.mSampleRate * secondPostion;
	endPacket /= context.asbd.mFramesPerPacket;
	
	context.startPacketIdx=startPacket;
	context.endPacketIdx=endPacket;
	
	context.file.packetIdx=startPacket;
    
    
    context.status=NO;

    // enqueue buffer
	for(int idx=0; idx<NUM_BUF; ++idx)
		AQOutputCallback(&context, context.queue, context.bufs[idx]);
    
    OSStatus status = AudioQueueStart(context.queue, NULL);
    if(status != noErr){
        NSLog(@"start audio queue error");
    }
    
    //_state=PLAYER_PLAYING;
    [self checkPlayState];
}


- (double)duration{
    return context.duration;
}

- (enum PLAYER_STATE)state{
    
    UInt32 runing;
    UInt32 size=sizeof(UInt32);
    AudioQueueGetProperty(context.queue,
                          kAudioQueueProperty_IsRunning,
                          &runing,
                          &size);
    if(_state!=PLAYER_INIT&&!runing)
        _state=PLAYER_STOP;

    return _state;
}

- (BOOL)isStop{
    UInt32 runing;
    UInt32 size=sizeof(UInt32);
    AudioQueueGetProperty(context.queue,
                          kAudioQueueProperty_IsRunning,
                          &runing,
                          &size);
    if(_state!=PLAYER_INIT&&!runing)
        _state=PLAYER_STOP;
    
    return !runing;
}
@end





















