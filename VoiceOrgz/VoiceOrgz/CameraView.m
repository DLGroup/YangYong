//
//  CameraView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/13/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "CameraView.h"
#import <QuartzCore/QuartzCore.h>
#import "SharedObj.h"
#import "VoiceListViewController.h"
#import "VoiceInfo.h"
#import "DirInfo.h"
#import "DLRecorder.h"
#import "GlobalObj.h"
#import "DLPlayer.h"
#import <sys/time.h>


#define MAX_COUNT 9
#define IMAGE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images"]


static NSString* defaultName(NSString *voiceName)
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    NSString *dateString=[NSString stringWithFormat:@"%@_%ld%d", voiceName, time.tv_sec, time.tv_usec];
    
	return [dateString stringByAppendingString:@".jpg"];
}

@interface CameraView()
- (void)updateImage;
- (void)timerCallback;
@end

@implementation CameraView
@synthesize pictureView=_pictureView;
@synthesize imgArray=_imgArray;
@synthesize ipc=_ipc;
@synthesize recordControlView=_recordControlView;
@synthesize recordView=_recordView;
@synthesize markView=_markView;
@synthesize textLabel=_textLabel;
@synthesize timeLabel=_timeLabel;
@synthesize dirInfo=_dirInfo;
@synthesize timer=_timer;
@synthesize pictureImageView=_pictureImageView;
@synthesize alertView=_alertView;
@synthesize cameraBtn=_cameraBtn;

- (void)viewWillDisappear:(BOOL)animated{
}

- (void)dealloc{
    NSLog(@"cameraview dealloc");
    [self.cameraBtn release];
    [self.alertView release];
    [self.pictureView release];
    [self.imgArray release];
    [self.recordControlView release];
    [self.recordView release];
    [self.markView release];
    [self.textLabel release];
    [self.timeLabel release];
    [self.pictureImageView release];
    [self.dirInfo release];
    [super dealloc];
}

- (void)showAlert{
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionDefault];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromBottom;
    animation.duration=0.5f;
    _alertView.hidden=NO;
    [_alertView.layer addAnimation:animation forKey:nil];
}

- (void)showLabel{
    if([GlobalObj globalObj].recorder.state==RECORDING || [GlobalObj globalObj].recorder.state==PAUSE){
        _textLabel.hidden=NO;
        _timeLabel.hidden=NO;
    }
    _cameraBtn.enabled=YES;
}
- (void)hiddenAlert{
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionDefault];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromBottom;
    animation.duration=0.5f;
    _alertView.hidden=YES;
    [_alertView.layer addAnimation:animation forKey:nil];
    [self performSelector:@selector(showLabel) withObject:nil afterDelay:0.8];

}


- (IBAction)snap:(id)sender {
    if(imageCount < MAX_COUNT){
        [_ipc takePicture];
    }
    else{
        _textLabel.hidden=YES;
        _timeLabel.hidden=YES;
        _cameraBtn.enabled=NO;
        [self showAlert];
        [self performSelector:@selector(hiddenAlert) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)returnCtl:(id)sender {
    if(_timer){
        [_timer invalidate];
        _timer=nil;
    }
    
    UINavigationController *controller=
    (UINavigationController*)_ipc.presentingViewController;

    VoiceListViewController *listController=nil;
    if([[controller topViewController] isKindOfClass:[VoiceListViewController class]]){
        listController=(VoiceListViewController*)[controller topViewController];
        
        if(listController.isRecording){
            [listController cancelRecordFromCamera];
            [[GlobalObj globalObj].recorder drop];
            
        }
        
    }

    [_ipc dismissViewControllerAnimated:NO completion:^{}];
}

- (void)timerCallback{
    
    if(!pause){
        int timeCounter=[GlobalObj globalObj].recorder.timeCounter;
        int timerMSecond = 0, timerMMSecond = 0, LSecond=0, HSecond=0, LMin=0, HMin=0;
        
        timerMMSecond=timeCounter%10;
        timerMSecond=timeCounter/10%10;
        LSecond=timeCounter/100%10;
        HSecond=timeCounter/1000%6;
        LMin=timeCounter/6000%10;
        HMin=timeCounter/60000%6;
        
        _timeLabel.text=[NSString stringWithFormat:@"%d%d:%d%d:%d%d",HMin,LMin, HSecond,LSecond,timerMSecond,timerMMSecond];
    }
    
}
- (IBAction)startRecord:(id)sender {
    _recordView.hidden=YES;
    _markView.image=[GlobalObj getImageFromFile:@"red_light.png"];
    
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    animation.duration=0.5f;
    _recordControlView.hidden=NO;
    [_recordControlView.layer addAnimation:animation forKey:nil];
    
    _textLabel.hidden=NO;
    _timeLabel.hidden=NO;
    
    _textLabel.text=@"Audio Recording";
    
    GlobalObj *globalObj=[GlobalObj globalObj];
    globalObj.recorder.timeCounter=0;
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    [globalObj.recorder start];
    
    _timeLabel.textColor=[UIColor whiteColor];
}


- (IBAction)stopRecord:(id)sender {
    if(_timer){
        [_timer invalidate];
        _timer=nil;
    }
    
    SharedObj *obj=[SharedObj sharedObj];
    
    GlobalObj *globalObj=[GlobalObj globalObj];
    [globalObj.recorder stop];
    
    NSDate *date=[NSDate date];
    VoiceInfo *info=[[VoiceInfo alloc]
                     initWithVoiceName:VOICE_DEFAULT_NAME
                     path:[globalObj.recorder filePath]
                     createDate:date
                     duration:[globalObj.recorder duration]
                     size:[globalObj.recorder size]
                     dir:_dirInfo.parent];
    
    NSString *fileName=[info.path lastPathComponent];
    NSString *voiceName=[fileName substringToIndex:fileName.length-4];
    for (int idx=0; idx<_imgArray.count; ++idx) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *path=[NSString stringWithFormat:@"%@/%@", IMAGE_FOLDER, defaultName(voiceName)];
        
        //max compression
        NSData *data=UIImageJPEGRepresentation([_imgArray objectAtIndex:idx], 1.0f);
        [data writeToFile:path atomically:NO];
        [info.imgArray addObject:path];
        
        [pool drain];
    }
    if(_imgArray.count > 0)
        info.imgIdx=0;
    
    [_imgArray removeAllObjects];
    
    UINavigationController *controller=(UINavigationController*)_ipc.presentingViewController;
    VoiceListViewController *listController=nil;
    BOOL onTopDir=YES;
    
    if([[controller topViewController] isKindOfClass:[VoiceListViewController class]]){
        listController=(VoiceListViewController*)[controller topViewController];
        onTopDir=NO;
        
        
        [obj.voice addObject:info];
        [listController.dirInfo.voices insertObject:[NSNumber numberWithInt:obj.voice.count-1]
                                            atIndex:0];
        if(!listController.isRecording){
            [listController.tableView beginUpdates];
            
            [listController.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            
            if(listController.selectedIdx >= 0) listController.selectedIdx++;
            [listController.tableView endUpdates];
        }
                        
        [listController stopRecordFromCamera:info];

    }
    else{
        listController=[[VoiceListViewController alloc]
                        initWithNibName:@"VoiceListViewController"
                        bundle:nil
                        dirInfo:_dirInfo
                        recording:NO
                        withVoice:info];
    }
    
    
    [_ipc dismissViewControllerAnimated:NO completion:^(void){
        if(onTopDir){
            [controller pushViewController:listController animated:NO];
            [listController release];
        }
        else{
            [listController selectFirstSection:info];
            
        }
        
        [info release];
    }];
}

- (IBAction)pauseRecord:(id)sender {
    pause=pause?NO:YES;
    if(pause){
        
        [[GlobalObj globalObj].recorder pause];
        _markView.image=[GlobalObj getImageFromFile:@"yellow_light.png"];
        _textLabel.text=@"Pause Recording";
        _textLabel.textColor=[UIColor yellowColor];
        _timeLabel.textColor=[UIColor yellowColor];
    }
    else{
        [[GlobalObj globalObj].recorder resume];
        _markView.image=[GlobalObj getImageFromFile:@"red_light.png"];
        _textLabel.text=@"Audio Recording";
        _timeLabel.textColor=[UIColor whiteColor];
        _textLabel.textColor=[UIColor whiteColor];

    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipc:(UIImagePickerController *)ipc dirInfo:(DirInfo *)dirInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imageCount=0;
        pause=NO;
        
        
        _ipc=ipc;
        _imgArray=[[NSMutableArray alloc] initWithCapacity:9];
        
        _dirInfo=[dirInfo retain];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *borderColor = [UIColor whiteColor];
    [_pictureImageView.layer setBorderColor:borderColor.CGColor];
    [_pictureImageView.layer setBorderWidth:2.0f];
    
    if([[GlobalObj globalObj].recorder state] == RECORDING){
        _markView.image=[GlobalObj getImageFromFile:@"red_light.png"];
        _textLabel.text=@"Audio Recording";
        _timeLabel.textColor=[UIColor whiteColor];
        
        _recordControlView.hidden=NO;
        _recordView.hidden=YES;
        _timeLabel.hidden=NO;
        _textLabel.hidden=NO;
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
        
    }
    else if([[GlobalObj globalObj].recorder state] == PAUSE){
        pause=YES;
        _markView.image=[GlobalObj getImageFromFile:@"yellow_light.png"];
        _textLabel.text=@"Pause Recording";
        _timeLabel.textColor=[UIColor yellowColor];
        _recordControlView.hidden=NO;
        _recordView.hidden=YES;
        _timeLabel.hidden=NO;
        _textLabel.hidden=NO;
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
        
        int timeCounter=[GlobalObj globalObj].recorder.timeCounter;
        int timerMSecond = 0, timerMMSecond = 0, LSecond=0, HSecond=0, LMin=0, HMin=0;
        
        timerMMSecond=timeCounter%10;
        timerMSecond=timeCounter/10%10;
        LSecond=timeCounter/100%10;
        HSecond=timeCounter/1000%6;
        LMin=timeCounter/6000%10;
        HMin=timeCounter/60000%6;
        
        _timeLabel.text=[NSString stringWithFormat:@"%d%d:%d%d:%d%d",HMin,LMin, HSecond,LSecond,timerMSecond,timerMMSecond];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateImage{
    UILabel *label=(UILabel*)[_pictureView viewWithTag:100];
    label.text=[NSString stringWithFormat:@"%d", imageCount];
    
    UIImageView *imageView=(UIImageView*)[_pictureView viewWithTag:101];
    imageView.image=[_imgArray objectAtIndex:imageCount-1];
    
    _pictureView.hidden=NO;
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [_imgArray addObject:image];
    
    imageCount++;
    [self updateImage];
}

- (void)viewDidUnload {
    [self setAlertView:nil];
    [self setCameraBtn:nil];
    [super viewDidUnload];
}
@end

















