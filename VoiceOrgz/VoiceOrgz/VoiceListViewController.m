//
//  VoiceListViewController.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/26/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "VoiceListViewController.h"
#import "SharedObj.h"
#import <QuartzCore/QuartzCore.h>
#import "VoiceInfo.h"
#import "VoiceMainView.h"
#import "DirInfo.h"
#import "CameraView.h"
#import "GlobalObj.h"
#import "DLRecorder.h"
#import "DLPlayer.h"
#import "TagView.h"

#define TABLEVIEWCELL_BACKGROUND_TAG    100
#define TABLEVIEWCELL_IMAGE_TAG         101
#define TABLEVIEWCELL_NAME_LABEL_TAG    102
#define TABLEVIEWCELL_DETAIL_1_TAG      103
#define TABLEVIEWCELL_DETAIL_2_TAG      104
#define TABLEVIEWCELL_BUTTON_TAG        105
#define TABLEVIEWCELL_PLAY_BUTTON_TAG   106

#define TABLEVIEWCELL_SLIDER_TAG        107
#define TABLEVIEWCELL_VOICE_TAG         108
#define TABLEVIEWCELL_TIMELABEL_1_TAG   109
#define TABLEVIEWCELL_TIMELABEL_2_TAG   110

#define TABLEVIEWCELL_MAIN_HEIGHT       54
#define TABLEVIEWCELL_SUB_HEIGHT        42


#define PICTURE_SHOW_HEIGHT 168

@interface VoiceListViewController ()
- (void)addRecordMarkView;
- (void)addRecordMaskView;

- (UITableViewCell*)voiceCell:(NSIndexPath*)indexPath;
- (UITableViewCell*)previewCell:(NSIndexPath*)indexPath;
- (void)voiceMainView:(id)sender;

- (void)normalView;
- (void)recordView;

- (void)timerCallback;
- (void)play:(id)sender;

- (void)pictureShowAnimation;
- (void)pictureHiddenAnimaiton;

-(UITableViewCell*)paddingCell;
@end

@implementation VoiceListViewController

@synthesize dirInfo=_dirInfo;
@synthesize isRecording=_isRecording;
@synthesize tableView=_tableView;
@synthesize recordMarkView=_recordMarkView;
@synthesize maskView=_maskView;
@synthesize recordControlView=_recordControlView;

@synthesize cameraView=_cameraView;
@synthesize recordingView=_recordingView;

@synthesize selectedIdx=_selectedIdx;
@synthesize layoutView=_layoutView;
@synthesize timer=_timer;
@synthesize pictureShowImageView=_pictureShowImageView;
@synthesize pictureShowBackgroundImageView=_pictureShowBackgroundImageView;
@synthesize pictureShowImageViewMask=_pictureShowImageViewMask;
@synthesize pictureHolderView=_pictureHolderView;
@synthesize playTimer=_playTimer;

@synthesize darkBackgroundView=_darkBackgroundView;
@synthesize recordBackgroundView=_recordBackgroundView;
@synthesize cameraBackgroundView=_cameraBackgroundView;
@synthesize pauseBackgroundView=_pauseBackgroundView;
@synthesize stopBackgroundView=_stopBackgroundView;

-(void)recordView{
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    animation.duration=0.25f;
    _cameraView.hidden=NO;
    [_cameraView.layer addAnimation:animation forKey:nil];
    
    [self startRecord:nil];
}

- (void)normalView{
    if([[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isMemberOfClass:[TagView class]])
        return;
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    animation.duration=0.25f;
    _cameraView.hidden=NO;
    _recordingView.hidden=NO;
    [_cameraView.layer addAnimation:animation forKey:nil];
    [_recordingView.layer addAnimation:animation forKey:nil];
    
}

- (void)cancelRecordFromCamera{
    [_timer invalidate];
    _timer=nil;
    
    _recordMarkView.hidden=YES;
    _maskView.hidden=YES;
    _recordControlView.hidden=YES;
    _recordingView.hidden=NO;
    
    [_tableView beginUpdates];
    _isRecording=NO;
    _tableView.scrollEnabled=YES;
    
    [_tableView  deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];

}


- (void)stopRecordFromCamera:(VoiceInfo*)info{
    [_timer invalidate];
    _timer=nil;
    
    _recordMarkView.hidden=YES;
    _maskView.hidden=YES;
    _recordControlView.hidden=YES;
    _recordingView.hidden=NO;
    
    [_tableView beginUpdates];
    _isRecording=NO;
    _tableView.scrollEnabled=YES;
    
    UITableViewCell *cell=[_tableView cellForRowAtIndexPath:
                           [NSIndexPath indexPathForItem:0 inSection:0]];
    
    UIButton *button=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_BUTTON_TAG];
    UIButton *playbutton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
    
    UIImageView *imageView=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_IMAGE_TAG];
    UILabel *nameLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_NAME_LABEL_TAG];
    //UILabel *detailLabel_1=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_1_TAG];
    UILabel *detailLabel_2=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_2_TAG];
    nameLabel.textColor=[UIColor whiteColor];
    
    // Change image and labels
    // ...
    imageView.contentMode=UIViewContentModeScaleToFill;
    if(info.imgArray.count > 0)
        imageView.image=[UIImage imageWithContentsOfFile:[info.imgArray objectAtIndex:info.imgIdx]];
    else
        imageView.image=nil;
    
    button.hidden=NO;
    playbutton.hidden=NO;
    nameLabel.text=@"Audio clip";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yy'-'MMM'-'dd'";
    detailLabel_2.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                        [formatter stringFromDate:info.createDate],
                        info.duration,
                        info.size/1024];

    [_tableView endUpdates];
}

- (IBAction)stopRecord:(id)sender{
    
    CATransition *animationMarkHidden=[CATransition animation];
    animationMarkHidden.timingFunction=[CAMediaTimingFunction
                                        functionWithName:kCAMediaTimingFunctionEaseOut];
    animationMarkHidden.type=kCATransitionReveal;
    animationMarkHidden.subtype=kCATransitionFromRight;
    animationMarkHidden.duration=0.5f;
    _recordMarkView.hidden=YES;
    [_recordMarkView.layer addAnimation:animationMarkHidden
                                 forKey:nil];
    
    
    CATransition *animationMaskHidden=[CATransition animation];
    animationMaskHidden.timingFunction=[CAMediaTimingFunction
                                        functionWithName:kCAMediaTimingFunctionEaseOut];
    animationMaskHidden.type=kCATransitionReveal;
    animationMaskHidden.subtype=kCATransitionFromBottom;
    animationMaskHidden.duration=0.5f;
    animationMaskHidden.delegate=self;
    _maskView.hidden=YES;
    _recordControlView.hidden=YES;
    _recordingView.hidden=NO;
    [_maskView.layer addAnimation:animationMaskHidden forKey:nil];
    [_recordControlView.layer addAnimation:animationMaskHidden forKey:nil];
    [_recordingView.layer addAnimation:animationMaskHidden forKey:nil];
    
    

    [_tableView beginUpdates];
    _isRecording=NO;
    _tableView.scrollEnabled=YES;
    [_timer invalidate];
    _timer=nil;
    UITableViewCell *cell=[_tableView cellForRowAtIndexPath:
                           [NSIndexPath indexPathForItem:0 inSection:0]];
    
    
    GlobalObj *global=[GlobalObj globalObj];
    [global.recorder stop];
    NSString* path=[global.recorder filePath];
    
    // Add voice
    VoiceInfo *newVoice=[[VoiceInfo alloc]
                         initWithVoiceName:@"Audio clip"
                         path:path
                         createDate:[NSDate date]
                         duration:[global.recorder duration]
                         size:[global.recorder size]
                         dir:_dirInfo.parent];
    
    [[SharedObj sharedObj].voice addObject:newVoice];
    [_dirInfo.voices insertObject:[NSNumber numberWithInt:[SharedObj sharedObj].voice.count-1] atIndex:0];
    
    // Update cell settings
    [self selectFirstSection:newVoice];
    
    UIButton *button=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_BUTTON_TAG];
    UIButton *playbutton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
    
    UIImageView *imageView=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_IMAGE_TAG];
    UILabel *nameLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_NAME_LABEL_TAG];
    //UILabel *detailLabel_1=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_1_TAG];
    UILabel *detailLabel_2=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_2_TAG];
    nameLabel.textColor=[UIColor whiteColor];
    
    // Change image and labels
    // ...
    imageView.contentMode=UIViewContentModeCenter;
    imageView.image=nil;
    
    button.hidden=NO;
    playbutton.hidden=NO;
    nameLabel.text=@"Audio clip";
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yy'-'MMM'-'dd'";
    detailLabel_2.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                        [formatter stringFromDate:newVoice.createDate],
                        newVoice.duration,
                        newVoice.size/1024];
    
    [_tableView endUpdates];
    
}

- (void)_startCamera{
    UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSLog(@"camera is not available");
        return;
    }
    
    ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    ipc.allowsEditing=NO;
    ipc.showsCameraControls=NO;
    
    ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.3);
    
    if(_layoutView)
        self.layoutView=nil;
    
    NSString *xibFile=@"CameraView";
    if([[UIScreen mainScreen] bounds].size.height==568){
        xibFile=@"CameraViewR";
        ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.42);

    }
    _layoutView=[[CameraView alloc] initWithNibName:xibFile bundle:nil
                                                ipc:ipc dirInfo:_dirInfo];
    ipc.cameraOverlayView=_layoutView.view;
    ipc.delegate=_layoutView;
    
    
    [self.navigationController presentViewController:ipc animated:NO completion:^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        
    }];

}

- (IBAction)startCamera:(id)sender {
    
    GlobalObj *globalObj=[GlobalObj globalObj];
    [globalObj.player stop];
    globalObj.player=nil;
    if(_playTimer){
        [_playTimer invalidate];
        _playTimer=nil;
    }
    [self performSelector:@selector(_startCamera) withObject:nil afterDelay:0.5f];
}

- (void)addRecordMarkView{
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromLeft;
    animation.duration=0.5f;
    _recordMarkView.hidden=NO;
    [_recordMarkView.layer addAnimation:animation forKey:nil];
}

- (void)addRecordMaskView{
    
    UITableViewCell *cell=[_tableView cellForRowAtIndexPath:
                           [NSIndexPath indexPathForItem:0 inSection:0]];
    
    float y=cell.frame.origin.y+cell.frame.size.height+5.0f;
    CGRect frame=_maskView.frame;
    frame.origin=CGPointMake(0.0, y);
    _maskView.frame=frame;
    
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromTop;
    animation.duration=0.5f;
    _maskView.hidden=NO;
    _recordControlView.hidden=NO;
    [_maskView.layer addAnimation:animation forKey:nil];
    [_recordControlView.layer addAnimation:animation forKey:nil];
    
}

- (void)timerCallback{
    int timeCounter=[GlobalObj globalObj].recorder.timeCounter;
    int timerMSecond = 0, timerMMSecond = 0, LSecond=0, HSecond=0, LMin=0, HMin=0;
    
    timerMMSecond=timeCounter%10;
    timerMSecond=timeCounter/10%10;
    LSecond=timeCounter/100%10;
    HSecond=timeCounter/1000%6;
    LMin=timeCounter/6000%10;
    HMin=timeCounter/60000%6;
    
    UITableViewCell *cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UILabel *nameLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_NAME_LABEL_TAG];
    
    nameLabel.text=[NSString stringWithFormat:@"%d%d:%d%d:%d%d",HMin,LMin, HSecond,LSecond,timerMSecond,timerMMSecond];
    
}

- (void)_startRecord{
    GlobalObj *globalObj=[GlobalObj globalObj];

    [self pictureHiddenAnimaiton];
    [_tableView setContentOffset:CGPointZero animated:NO];
    _tableView.scrollEnabled=NO;
    
    [_tableView beginUpdates];
    if(_selectedIdx>=0){
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:_selectedIdx]] withRowAnimation:UITableViewRowAnimationAutomatic];
        _selectedIdx=-1;
    }

    _isRecording=YES;
    
    [_tableView  insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    if(_selectedIdx >= 0) ++_selectedIdx;
    [_tableView endUpdates];
    
    _recordingView.hidden=YES;
    
    [self addRecordMarkView];
    [self addRecordMaskView];
    
    
    
    globalObj.recorder.timeCounter=0;
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    [globalObj.recorder start];

}

- (IBAction)startRecord:(id)sender{
    
    GlobalObj *globalObj=[GlobalObj globalObj];
    [globalObj.player stop];
    globalObj.player=nil;
    if(_playTimer){
        [_playTimer invalidate];
        _playTimer=nil;
    }
    [self performSelector:@selector(_startRecord) withObject:nil afterDelay:0.5f];
}


- (void)updatePlayerDuration{
    if(_selectedIdx >=0 ){
        NSIndexPath *path=[NSIndexPath indexPathForItem:1 inSection:_selectedIdx];
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:path];
        
        GlobalObj *globalObj=[GlobalObj globalObj];

        if(cell){
            UILabel *leftLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_TIMELABEL_1_TAG];
            UILabel *rightLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_TIMELABEL_2_TAG];
            UISlider *slider=(UISlider*)[cell viewWithTag:TABLEVIEWCELL_SLIDER_TAG];
            
            if([globalObj.player state] == PLAYER_PLAYING){
                float duration=[globalObj.player duration];
                float currentProgress=[globalObj.player estimateProgress];
                
                leftLabel.text=[NSString stringWithFormat:@"%.2f", duration];
                rightLabel.text=[NSString stringWithFormat:@"-%.2f", duration*(1.0f-currentProgress)];
                
                slider.value=currentProgress;
            }
            if([globalObj.player isStop]){
                UITableViewCell *voiceCell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_selectedIdx]];
                UIButton *playButton=(UIButton*)[voiceCell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
                [self play:playButton];
                [_playTimer invalidate];
                _playTimer=nil;
            }
        }
    }
}

-(void)selectFirstSection:(VoiceInfo*)voice{
    
    int lastSelectedIdx=_selectedIdx;
    _selectedIdx=0;
    NSIndexPath *insertPath=[NSIndexPath indexPathForItem:1
                                                inSection:0];
    NSIndexPath *lastPath=[NSIndexPath indexPathForItem:1
                                              inSection:lastSelectedIdx];
    
    if(!_playTimer){
        _playTimer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
    }
    [_tableView beginUpdates];
    if(lastSelectedIdx < 0){
        
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:insertPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *insertSectionRow0=[NSIndexPath indexPathForItem:0
                                                           inSection:0];
        UIButton *playButton=(UIButton*)[[_tableView cellForRowAtIndexPath:insertSectionRow0] viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        [playButton setImage:[GlobalObj getImageFromFile:@"playlist_roundicon.png"] forState:UIControlStateNormal];
    }
    
    else{
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:lastPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        NSIndexPath *deleteSectionRow0=[NSIndexPath indexPathForItem:0
                                                           inSection:lastSelectedIdx];
        UIButton *playButton=(UIButton*)[[_tableView cellForRowAtIndexPath:deleteSectionRow0] viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        int idx=[[_dirInfo.voices objectAtIndex:lastPath.section] intValue];
        VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];
        
        if(info.imgArray.count > 0)
            [playButton setImage:[GlobalObj getImageFromFile:@"audioplaylist_icon.png"] forState:UIControlStateNormal];
        else
            [playButton setImage:[GlobalObj getImageFromFile:@"blueplayer.png"] forState:UIControlStateNormal];
        
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:insertPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *insertSectionRow0=[NSIndexPath indexPathForItem:0
                                                           inSection:insertPath.section];
        playButton=(UIButton*)[[_tableView cellForRowAtIndexPath:insertSectionRow0] viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        idx=[[_dirInfo.voices objectAtIndex:insertPath.section] intValue];
        info=[[SharedObj sharedObj].voice objectAtIndex: idx];
        [playButton setImage:[GlobalObj getImageFromFile:@"playlist_roundicon.png"] forState:UIControlStateNormal];
    }
    
    [_tableView endUpdates];
    
    
    int idx=[[_dirInfo.voices objectAtIndex:insertPath.section] intValue];
    VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];
    
    if(info.imgArray.count>0){
        CGRect frame=_tableView.frame;
        frame.origin.y=PICTURE_SHOW_HEIGHT;
        
        [UIView
         animateWithDuration:0.5
         animations:^{
             _tableView.frame=frame;
         }];
        
        _pictureShowImageView.image = [UIImage imageWithContentsOfFile:[info.imgArray objectAtIndex:info.imgIdx]];
        [self pictureShowAnimation];
    }
    
    
    GlobalObj *global=[GlobalObj globalObj];
    global.player=[[DLPlayer alloc] initWithAudioFileURL:voice.path];
    [global.player play];

}

- (IBAction)pause:(id)sender {
    if([GlobalObj globalObj].recorder.state==RECORDING){
        _recordMarkView.hidden=YES;
        
        _recordMarkView.image=[GlobalObj getImageFromFile:@"pause_recording_txt.png"];
        [self addRecordMarkView];
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView *imageView=(UIImageView*)[cell viewWithTag:101];
        imageView.image=[GlobalObj getImageFromFile:@"yellow_light.png"];
        
        UILabel *label=(UILabel*)[cell viewWithTag:102];
        label.textColor=[UIColor yellowColor];
        [[GlobalObj globalObj].recorder pause];
    }
    else{
        _recordMarkView.hidden=YES;
        
        _recordMarkView.image=[GlobalObj getImageFromFile:@"recording_mark.png"];;
        [self addRecordMarkView];
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView *imageView=(UIImageView*)[cell viewWithTag:101];
        imageView.image=[GlobalObj getImageFromFile:@"red_light.png"];
        
        UILabel *label=(UILabel*)[cell viewWithTag:102];
        label.textColor=[UIColor redColor];
        [[GlobalObj globalObj].recorder resume];

    }
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil dirInfo:(DirInfo *)dirInfo recording:(BOOL)recording withVoice:(VoiceInfo *)voice{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=[dirInfo.parent copy];
        
        UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem=backBarBtnItem;
        backBarBtnItem.tintColor=[UIColor blackColor];
        
        SharedObj *obj=[SharedObj sharedObj];
        
        _dirInfo=dirInfo;
        
        /*if([_dirInfo.parent compare:@"Recordings"] ==  NSOrderedSame){
            [_dirInfo.voices removeAllObjects];
            for(int idx=0; idx<obj.voice.count; ++idx)
                [_dirInfo.voices addObject:[NSNumber numberWithInt:idx]];
            
        }*/
        
        if(voice){
            [obj.voice addObject:voice];
            [_dirInfo.voices insertObject:[NSNumber numberWithInt:obj.voice.count-1]
                                  atIndex:0];
            [self performSelector:@selector(selectFirstSection:) withObject:voice afterDelay:0.5f];
            
        }
        if(recording)
            [self performSelector:@selector(recordView) withObject:nil afterDelay:0.5f];
        else
            [self performSelector:@selector(normalView) withObject:nil afterDelay:0.5f];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.backgroundView=[[UIImageView alloc] initWithImage:
                               [GlobalObj getImageFromFile:@"voice_main_ctl_background.png"]];
    
    _selectedIdx=-1;
    _pictureHolderView.hidden=YES;
    
    UIColor *borderColor = [UIColor whiteColor];
    [_pictureShowImageView.layer setBorderColor:borderColor.CGColor];
    [_pictureShowImageView.layer setBorderWidth:3.0f];
    
    _darkBackgroundView.image=[GlobalObj getImageFromFile:@"dark_bckgd.png"];
    _recordBackgroundView.image=[GlobalObj getImageFromFile:@"recording_btn_background.png"];

    _cameraBackgroundView.image=[GlobalObj getImageFromFile:@"camera_btn_background.png"];
    _pauseBackgroundView.image=[GlobalObj getImageFromFile:@"pause_btn_background.png"];

    _stopBackgroundView.image=[GlobalObj getImageFromFile:@"stop_btn_background.png"];
    
    _recordMarkView.image=[GlobalObj getImageFromFile:@"recording_mark.png"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"voicelist memory warning");
    self.layoutView=nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_isRecording&&section==0)
        return 35.0f;
    else
        return 5.0f;
}


-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(section >= _dirInfo.voices.count)
        return nil;
    
    UIImageView *imageView=[[UIImageView alloc]
                            initWithImage:[GlobalObj getImageFromFile:@"clip_sepector.png"]];
    
    imageView.contentMode=UIViewContentModeCenter;
    return imageView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(_isRecording)
        
        // 2 for padding sections, 1 for recording section
        return _dirInfo.voices.count+3;
    else
        return _dirInfo.voices.count+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_selectedIdx >= 0 && _selectedIdx==section)
        return 2;
    else
        return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==_selectedIdx && indexPath.row==1)
        return TABLEVIEWCELL_SUB_HEIGHT;
    else
        return TABLEVIEWCELL_MAIN_HEIGHT;
}

- (void)play:(id)sender{
    UITableViewCell *cell=(UITableViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    GlobalObj *global=[GlobalObj globalObj];
    
    if(_isRecording)
        return;
    
    int lastSelectedIdx=_selectedIdx;
    _selectedIdx=indexPath.section;
    NSIndexPath *insertPath=[NSIndexPath indexPathForItem:1
                                                inSection:indexPath.section];
    NSIndexPath *lastPath=[NSIndexPath indexPathForItem:1
                                              inSection:lastSelectedIdx];
    
    BOOL needPlay=YES;
    [_tableView beginUpdates];
    if(lastSelectedIdx < 0){
        
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:insertPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        UIButton *playButton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        [playButton setImage:[GlobalObj getImageFromFile:@"playlist_roundicon.png"] forState:UIControlStateNormal];
        
    }
    
    else if(lastSelectedIdx == _selectedIdx){
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:lastPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        UIButton *playButton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        
        int idx=[[_dirInfo.voices objectAtIndex:indexPath.section] intValue];
        VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];
        
        if(info.imgArray.count > 0)
            [playButton setImage:[GlobalObj getImageFromFile:@"audioplaylist_icon.png"] forState:UIControlStateNormal];
        else
            [playButton setImage:[GlobalObj getImageFromFile:@"blueplayer.png"] forState:UIControlStateNormal];
        
        _selectedIdx=-1;
        [global.player stop];
        global.player=nil;
        needPlay=NO;
    }
    
    else{
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:lastPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *deleteSectionRow0=[NSIndexPath indexPathForItem:0
                                                           inSection:lastSelectedIdx];
        UIButton *playButton=(UIButton*)[[_tableView cellForRowAtIndexPath:deleteSectionRow0] viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        int idx=[[_dirInfo.voices objectAtIndex:lastPath.section] intValue];
        VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];
        
        [global.player stop];
        global.player=nil;
        if(info.imgArray.count > 0)
            [playButton setImage:[GlobalObj getImageFromFile:@"audioplaylist_icon.png"] forState:UIControlStateNormal];
        else
            [playButton setImage:[GlobalObj getImageFromFile:@"blueplayer.png"] forState:UIControlStateNormal];
        
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:insertPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *insertSectionRow0=[NSIndexPath indexPathForItem:0
                                                           inSection:indexPath.section];
        playButton=(UIButton*)[[_tableView cellForRowAtIndexPath:insertSectionRow0] viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        idx=[[_dirInfo.voices objectAtIndex:insertPath.section] intValue];
        info=[[SharedObj sharedObj].voice objectAtIndex: idx];
        [playButton setImage:[GlobalObj getImageFromFile:@"playlist_roundicon.png"] forState:UIControlStateNormal];
        
    }
    [_tableView endUpdates];
    
    
    int idx=[[_dirInfo.voices objectAtIndex:indexPath.section] intValue];
    VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];

    
    if(_selectedIdx >= 0 && info.imgArray.count > 0){
        
        CGRect rectInTableView = [_tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [_tableView convertRect:rectInTableView toView:self.view];
    
        float y=rectInSuperview.origin.y;
        if(indexPath.section==0)
            y -= 5.0f;
        else
            y -= 7.0f;
        CGRect frame=_tableView.frame;
        if(y < PICTURE_SHOW_HEIGHT){
            
            float offset=PICTURE_SHOW_HEIGHT-y;
            if(_tableView.contentOffset.y >= offset){
                CGPoint currentOffset=_tableView.contentOffset;
                currentOffset.y -= offset;
                _tableView.contentOffset=currentOffset;
            }
            
            else{
                
                offset -= _tableView.contentOffset.y;
                CGPoint currentOffset=_tableView.contentOffset;
                currentOffset.y=0.0f;
                _tableView.contentOffset=currentOffset;
                
                frame.origin.y=offset;
                [UIView
                 animateWithDuration:0.5
                 animations:^{
                     _tableView.frame=frame;
                 }];
            }
        }
        
        else{
            CGPoint currentOffset=_tableView.contentOffset;
            currentOffset.y += y-PICTURE_SHOW_HEIGHT;
            _tableView.contentOffset=currentOffset;
        }
        
        if(info.imgArray.count > 0){
            _pictureShowImageView.image=[UIImage imageWithContentsOfFile:[info.imgArray objectAtIndex:info.imgIdx]];
            [self pictureShowAnimation];
        }
        
       
    }
    
    else{
        CGRect frame=_tableView.frame;
        frame.origin.y=0.0f;
        [UIView
         animateWithDuration:0.5
         animations:^{
             _tableView.frame=frame;
         }];

        [self pictureHiddenAnimaiton];
    }
    
    if(needPlay){
        global.player=[[DLPlayer alloc] initWithAudioFileURL:info.path];
        [global.player play];
        
    }
    if(!_playTimer){
        _playTimer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
    }
}


- (void)pictureShowAnimation{
    
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionDefault];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromBottom;
    animation.duration=0.5f;
    _pictureHolderView.hidden=NO;
    _pictureShowImageViewMask.hidden=NO;
    [_pictureHolderView.layer addAnimation:animation forKey:nil];
    [_pictureShowImageViewMask.layer addAnimation:animation forKey:nil];

}

- (void)pictureHiddenAnimaiton{
    CGRect frame=_tableView.frame;
    frame.origin.y=0.0f;
    _tableView.frame=frame;
    
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionDefault];
    animation.type=kCATransitionReveal;
    animation.subtype=kCATransitionFromTop;
    animation.duration=0.5f;
    _pictureHolderView.hidden=YES;
    _pictureShowImageViewMask.hidden=YES;
    [_pictureHolderView.layer addAnimation:animation forKey:nil];
    [_pictureShowImageViewMask.layer addAnimation:animation forKey:nil];
}

- (void)voiceMainView:(id)sender{
    
    UITableViewCell *cell=(UITableViewCell*)[[sender superview] superview];
    NSIndexPath *path=[_tableView indexPathForCell:cell];
    
    VoiceInfo *info=[[SharedObj sharedObj].voice
                     objectAtIndex:[[_dirInfo.voices objectAtIndex:path.section] intValue]];
    
    VoiceMainView *voiceMainView=[[VoiceMainView alloc] initWithNibName:@"VoiceMainView" bundle:nil voice:info dirName:info.dir];
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:_dirInfo.parent style:UIBarButtonItemStyleBordered target:nil action:nil];
    backItem.tintColor=[UIColor blackColor];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    [self.navigationController pushViewController:voiceMainView animated:YES];
}

-(UITableViewCell*)paddingCell{
    static NSString *TableIdentifier = @"PaddingCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:
                             TableIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    cell.hidden=YES;
    return cell;
}

- (UITableViewCell*)voiceCell:(NSIndexPath *)indexPath{
    
    static NSString *TableIdentifier = @"BaseCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:
                             TableIdentifier];
    
    UIButton *button=nil;
    UIImageView *imageView=nil;
    UIButton *playButton=nil;
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"VoiceCell" owner:self options:nil] lastObject];
        
        UIImageView *background=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_BACKGROUND_TAG];
        background.image=[GlobalObj getImageFromFile:@"clip_background.png"];
        
        button=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_BUTTON_TAG];
        [button addTarget:self action:@selector(voiceMainView:)
         forControlEvents:UIControlEventTouchUpInside];
        
        playButton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        [playButton addTarget:self action:@selector(play:)
             forControlEvents:UIControlEventTouchUpInside];
        
        imageView=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_IMAGE_TAG];
        
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:11.0f];
        
    }
    
    UILabel *nameLabel=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_NAME_LABEL_TAG];
    //UILabel *detailLabel_1=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_1_TAG];
    UILabel *detailLabel_2=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_DETAIL_2_TAG];
    nameLabel.textColor=[UIColor whiteColor];
    playButton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
    
    
    // Recording cell settings
    if(_isRecording && indexPath.section==0){
        button.hidden=YES;
        playButton.hidden=YES;
        nameLabel.textColor=[UIColor redColor];
        detailLabel_2.text=@"WAVE/PCM, 8kHz, 16Bit";
        imageView.image=[GlobalObj getImageFromFile:@"red_light.png"];
        imageView.contentMode=UIViewContentModeCenter;
        
        return cell;
    }
    
    // Change image and labels
    // ...
    imageView=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_IMAGE_TAG];
    
    UIImage *image=nil;
    int idx=[[_dirInfo.voices objectAtIndex:indexPath.section] intValue];
    VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex: idx];
    
    nameLabel.text=info.name;
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yy'-'MMM'-'dd'";
    detailLabel_2.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                        [formatter stringFromDate:info.createDate],
                        info.duration,
                        info.size/1024];
    if(_dirInfo.voices.count > indexPath.section){
        if(info.imgIdx >= 0){
            image=[UIImage imageWithContentsOfFile:[info.imgArray objectAtIndex:info.imgIdx]];
        }
    }
    
    if(info.imgArray.count > 0)
        [playButton setImage:[GlobalObj getImageFromFile:@"audioplaylist_icon.png"] forState:UIControlStateNormal];
    else
        [playButton setImage:[GlobalObj getImageFromFile:@"blueplayer.png"] forState:UIControlStateNormal];
    
    imageView.image=image;
    playButton.hidden=NO;
    
    if(image.size.height > imageView.frame.size.height ||
       image.size.width > imageView.frame.size.width){
        imageView.contentMode=UIViewContentModeScaleToFill;
    }
    else
        imageView.contentMode=UIViewContentModeCenter;
    
    
    
    return cell;
}


- (void)didBeginChangeProgress:(id)sender {
    if(_playTimer){
        [_playTimer invalidate];
        _playTimer=nil;
        
        [[GlobalObj globalObj].player stop];
    }
}

- (void)didEndChangeProgress:(id)sender {
    
    GlobalObj *global=[GlobalObj globalObj];
    global.player=[[DLPlayer alloc] initWithAudioFileURL:global.player.path];
    
    [global.player setProgressWithFloat:((UISlider*)sender).value];

    
    _playTimer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
    
}



-(UITableViewCell*)previewCell:(NSIndexPath *)indexPath{
    static NSString *TableIdentifier = @"PreviewCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:
                             TableIdentifier];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"PreviewCell" owner:self options:nil] lastObject];
        
        UISlider *slider=(UISlider*)[cell viewWithTag:TABLEVIEWCELL_SLIDER_TAG];
        [slider addTarget:self action:@selector(didBeginChangeProgress:) forControlEvents:UIControlEventTouchDragInside];
        [slider addTarget:self action:@selector(didEndChangeProgress:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_selectedIdx==indexPath.section && indexPath.row==1)
        return [self previewCell:indexPath];
    else if(indexPath.section>=_dirInfo.voices.count && !_isRecording){
        return [self paddingCell];
    }
    else
        return [self voiceCell:indexPath];
}

- (void)viewWillAppear:(BOOL)animated{
    if(_layoutView)
        _layoutView=nil;

    [_tableView reloadData];

}

//invalidate timer!!!
- (void)viewWillDisappear:(BOOL)animated{
    //if(_isRecording!=RECORDING){
        [_timer invalidate];
        _timer=nil;
    //}
    
    [_playTimer invalidate];
    _playTimer=nil;
    
    if([GlobalObj globalObj].player){
       [[GlobalObj globalObj].player stop];
        [GlobalObj globalObj].player=nil;
    }
    
}


- (void)viewDidDisappear:(BOOL)animated{
    if(!_isRecording&&_selectedIdx>=0){        
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_selectedIdx]];
        
        UIButton *playButton=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_PLAY_BUTTON_TAG];
        [self play:playButton];
        
    }

}
- (void)dealloc{
    NSLog(@"voicelist dealloc");
    _layoutView=nil;
    _playTimer=nil;
    _timer=nil;
}
@end







