//
//  VoiceMainView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/12/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "VoiceMainView.h"
#import <QuartzCore/QuartzCore.h>
#import "SharedObj.h"
#import "VoiceInfo.h"
#import "SideshowView.h"
#import "GlobalObj.h"
#import "DLPlayer.h"
#import "TrimViewConroller.h"
#import "AddPicView.h"
#import "DirInfo.h"
#import "VoiceListViewController.h"
#import "MoveView.h"
#import "VoiceTag.h"
#import "RenameView.h"

#define IMAGE_WIDTH     115
#define IMAGE_HEIGHT    84

#define TAG_WIDTH       22
#define TAG_HEIGHT      23

@interface MyImageView:UIImageView
@property  int imageIdx;

- (id)initWithFrame:(CGRect)aRect idx:(int)idx;
@end

@implementation MyImageView
@synthesize imageIdx;
- (id)initWithFrame:(CGRect)aRect idx:(int)idx{
    self=[super initWithFrame:aRect];
    self.imageIdx=idx;
    return self;
}
@end

@interface VoiceMainView ()
- (void)addScrollSubViews:(UIScrollView*)scrollView;
@end

@implementation VoiceMainView
@synthesize scrollView=_scrollView;
@synthesize mainImageView=_mainImageView;
@synthesize imageCountLabel=_imageCountLabel;
@synthesize mainTopView=_mainTopView;
@synthesize leftLabel=_leftLabel;
@synthesize rightLabel=_rightLabel;
@synthesize slider=_slider;
@synthesize timer=_timer;
@synthesize audioScriptLabel=_audioScriptLabel;
@synthesize ipc=_ipc;
@synthesize layoutView=_layoutView;
@synthesize dirLabel=_dirLabel;
@synthesize dirName=_dirName;
@synthesize editSheet=_editSheet;
@synthesize deleteSheet=_deleteSheet;
@synthesize tagScrollView=_tagScrollView;
@synthesize startBtn=_startBtn;
@synthesize pauseBtn=_pauseBtn;
@synthesize shareSheet=_shareSheet;
@synthesize clipName=_clipName;

- (void)_trimShow{
    /*if(![GlobalObj globalObj].player.isCalculateSamples){
     [self performSelector:@selector(_trimShow) withObject:nil afterDelay:1.0f];
     return;
     }*/
    
    TrimViewConroller *trimViewController=[[TrimViewConroller alloc]
                                           initWithNibName:@"TrimViewConroller" bundle:nil voice:_voice dirName:_dirName];
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:_voice.name style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    backBarBtnItem.tintColor=[UIColor blackColor];
    self.navigationItem.backBarButtonItem=backBarBtnItem;
    
    UINavigationController *nav=self.navigationController;
    [nav pushViewController:trimViewController animated:YES];
    [backBarBtnItem release];
    [trimViewController release];
}

- (void)_tagShow{
    VoiceTag *voiceTag=[[VoiceTag alloc] initWithNibName:@"VoiceTag" bundle:nil];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:voiceTag];
    [navigationController.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
    
    [self presentModalViewController:navigationController animated:YES];
    
    [voiceTag release];
    [navigationController release];
}

- (void)_rename{
    RenameView *renameView=[[RenameView alloc] initWithNibName:@"RenameView" bundle:nil];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:renameView];
    [navigationController.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
    
    [self presentModalViewController:navigationController animated:YES];
    
    [renameView release];
    [navigationController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet==_editSheet){
        switch (buttonIndex) {
                //Tag
            case 0:
                [self _tagShow];
                break;
                //Rename
            case 1:
                [self _rename];
                break;
                //trim
            case 2:
                [self _trimShow];
                break;
                
            default:
                break;
        }
    }
    
    else if(actionSheet==_deleteSheet){
        switch (buttonIndex) {
                //delete
            case 0:
                [self _del];
                break;
                
                //Cancel
            case 1:
                break;
            default:
                break;
        }
    }
    
    else if(actionSheet == _shareSheet){
        switch (buttonIndex) {
            case 0:
                [self _share];
                break;
                
            default:
                break;
        }
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setTitle:@"Audio clip"];
    [picker setSubject:@"Audio clip created using VoiceOrgz"];
    picker.mailComposeDelegate = self;
    
    //Attach voice file
    NSData *voiceData=[NSData dataWithContentsOfFile:_voice.path];
    [picker addAttachmentData: voiceData mimeType: @"audio/aiff" fileName: @"Audio_clip.aif"];
    
    //Attach image file
    for(int i=0; i<_voice.imgArray.count; ++i){
        UIImage *img = [UIImage imageWithContentsOfFile:[_voice.imgArray objectAtIndex:i]];
        NSData *imageData = UIImagePNGRepresentation(img);
        [picker addAttachmentData: imageData mimeType: @"image/jpeg" fileName: [NSString stringWithFormat:@"image-%d.jpg", i+1]];
    }
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:";
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)_share{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}


- (void)edit{
    if(!_editSheet)
        _editSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tags",@"Rename",@"Trim", nil];
    
    [_editSheet showInView:self.view];
}

- (void)_slideShow:(int)idx{
    
    SideshowView *sideshowView=[[SideshowView alloc]
                                initWithNibName:@"SideshowView" bundle:nil voice:_voice idx:idx];
    
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:_voice.name style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    backBarBtnItem.tintColor=[UIColor blackColor];
    self.navigationItem.backBarButtonItem=backBarBtnItem;
    
    [self.navigationController pushViewController:sideshowView animated:YES];
    [sideshowView release];
    [backBarBtnItem release];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo *)voice dirName:(NSString *)dirName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _dirName=[dirName copy];
        _voice=[voice retain];
        GlobalObj *globalObj=[GlobalObj globalObj];
        
        if(globalObj.player && ![globalObj.player.path isEqualToString:_voice.path]){
            [globalObj.player stop];
            globalObj.player=nil;
        }
        
        if(!globalObj.player){
            DLPlayer *player=nil;
            player=[[DLPlayer alloc] initWithAudioFileURL:_voice.path];
            globalObj.player=player;
            [player release];
        }
        
        lastImgCnt=_voice.imgArray.count;
        

        UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
        rightBarBtnItem.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem=rightBarBtnItem;
        [rightBarBtnItem release];
    }
    return self;
}


- (void)startCamera{

    _ipc=[[UIImagePickerController alloc] init];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSLog(@"camera is not available");
        return;
    }
    
    _ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    _ipc.allowsEditing=NO;
    _ipc.showsCameraControls=NO;
    
    _ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.3);
    
    NSString *xibFile=@"AddPicView";
    if([[UIScreen mainScreen] bounds].size.height==568){
        xibFile=@"AddPicViewR";
        _ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.42);

    }
    _layoutView=[[AddPicView alloc] initWithNibName:xibFile bundle:nil ipc:_ipc voice:_voice];
    _ipc.cameraOverlayView=_layoutView.view;
    _ipc.delegate=(id)_layoutView;
    
    
    [self presentViewController:_ipc animated:YES completion:^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        
    }];
    
}


- (void) handleSingleTap:(UITapGestureRecognizer *) gestureRecognizer{
    MyImageView *myImageView=(MyImageView*)gestureRecognizer.view;
    if(myImageView.imageIdx<_voice.imgArray.count)
        [self _slideShow:myImageView.imageIdx];
    else{
        //Bring to camera
        [self startCamera];
    }
}


- (void)addTagScrollView{
    int xoffset=15.0f;
    int yoffset=10.0f;
    
    for(int idx=0; idx<_voice.tag.count; ++idx){
       UIView *tagLabel = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"TagLabel" owner:self options:nil] lastObject];
        
        UIImageView *imageView=(UIImageView*)[tagLabel viewWithTag:102];
        CGRect imageFrame=imageView.frame;
        
        UILabel *label=(UILabel*)[tagLabel viewWithTag:101];
        label.text=[_voice.tag objectAtIndex:idx];
        
        CGFloat labelWidth=label.frame.size.width;
        CGFloat _width = [label.text sizeWithFont:[UIFont italicSystemFontOfSize:10.0f]].width;
        
        CGRect frame=tagLabel.frame;
        frame.origin.x = xoffset;
        frame.origin.y=yoffset;
        frame.size.width-=(labelWidth-_width);
        tagLabel.frame=frame;
        
        imageView.frame=imageFrame;
        CGRect labelFrame=label.frame;
        labelFrame.size.width=_width;
        label.frame=labelFrame;
        
        xoffset += tagLabel.frame.size.width+15.0f;
        [_tagScrollView addSubview:tagLabel];
    }
    
    _tagScrollView.contentSize=CGSizeMake(xoffset,
                                      _tagScrollView.frame.size.height);
}


-(void)addScrollSubViews:(UIScrollView *)scrollView{
    UIImage *image=nil;
    int offset=10.0f;
    
    for(int idx=0; idx<=_voice.imgArray.count; ++idx){
        
        if(idx==_voice.imgArray.count){
            if(idx<=8)
                image=[UIImage imageNamed:@"add_picture_btn.png"];
            else
                break;
        }
        else
            image=[[UIImage alloc] initWithContentsOfFile:[_voice.imgArray objectAtIndex:idx]];
        
        
        UIImageView *imageView=[[MyImageView alloc] initWithFrame:CGRectMake(offset,
                                                                             10.0f,
                                                                             IMAGE_WIDTH,
                                                                             IMAGE_HEIGHT) idx:idx];
        
        if(image.size.height > imageView.frame.size.height ||
           image.size.width > imageView.frame.size.width){
            imageView.contentMode=UIViewContentModeScaleToFill;
        }
        else
            imageView.contentMode=UIViewContentModeCenter;

        imageView.userInteractionEnabled=YES;
        imageView.image=image;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        
        [imageView addGestureRecognizer:singleTap];
        
        [singleTap release];
        
        UIColor *borderColor = [UIColor whiteColor];
        [imageView.layer setBorderColor:borderColor.CGColor];
        [imageView.layer setBorderWidth:1.0f];
        
        [scrollView addSubview:imageView];
        
        //be care!!!
        if(idx!=_voice.imgArray.count)
            [image release];
        
        [imageView release];
        
        offset += IMAGE_WIDTH + 10.0f;
    }
    
    scrollView.contentSize=CGSizeMake(offset,
                                       _scrollView.frame.size.height);
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     
    self.title=_voice.name;
    _dirLabel.text=[NSString stringWithFormat:@"VoiceOrgz-%@", _dirName];
    
    [_mainImageView.layer setMasksToBounds:YES];
    [_mainImageView.layer setCornerRadius:11.0f];
    
    UIImage *image=nil;
    BOOL userImage=NO;
    if(_voice.imgIdx >= 0){
        image=[[UIImage alloc]initWithContentsOfFile:[_voice.imgArray objectAtIndex:_voice.imgIdx]];
        if(image)
            userImage=YES;
    }
    
    //if(!userImage)
    //    image=[GlobalObj getImageFromFile:@"red_light.png"];
    
    
    _mainImageView.image=image;
    if(userImage)
        [image release];

    if(image.size.height > _mainImageView.frame.size.height ||
       image.size.width > _mainImageView.frame.size.width){
        _mainImageView.contentMode=UIViewContentModeScaleToFill;
    }
    else
        _mainImageView.contentMode=UIViewContentModeCenter;
        
    if(_voice.imgArray&&_voice.imgArray.count>0)
        _imageCountLabel.text=[NSString stringWithFormat:@"%d", _voice.imgArray.count];
    else
        _imageCountLabel.text=@"0";
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yy'-'MMM'-'dd'";
    _audioScriptLabel.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                            [formatter stringFromDate:_voice.createDate],
                            _voice.duration,
                            _voice.size/1024];
    [formatter release];
    
    [_slider addTarget:self action:@selector(didBeginChangeProgress:) forControlEvents:UIControlEventTouchDragInside];
    [_slider addTarget:self action:@selector(didEndChangeProgress:) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"voicemain memory warning");
    if ([self.view window] == nil)
        self.view = nil;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
    _timer=nil;
    if([GlobalObj globalObj].player){
        [[GlobalObj globalObj].player stop];
        [[GlobalObj globalObj].player release];
        [GlobalObj globalObj].player=nil;
    }
    
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[_tagScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if(_ipc){
        [_ipc release];
        [_layoutView release];
        _ipc=nil;
        _layoutView=nil;
    }
    
    if(lastImgCnt!=_voice.imgArray.count){
        UIImage *image=nil;
        BOOL userImage=NO;
        if(_voice.imgIdx >= 0){
            image=[[UIImage alloc]initWithContentsOfFile:[_voice.imgArray objectAtIndex:_voice.imgIdx]];
            if(image)
                userImage=YES;
        }
        
        
        _mainImageView.image=image;
        if(userImage)
            [image release];
        
        if(image.size.height > _mainImageView.frame.size.height ||
           image.size.width > _mainImageView.frame.size.width){
            _mainImageView.contentMode=UIViewContentModeScaleToFill;
        }
        else
            _mainImageView.contentMode=UIViewContentModeCenter;
        
        [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self addScrollSubViews:_scrollView];
        
        if(_voice.imgArray&&_voice.imgArray.count>0)
            _imageCountLabel.text=[NSString stringWithFormat:@"%d", _voice.imgArray.count];
        else
            _imageCountLabel.text=@"0";
        
        lastImgCnt=_voice.imgArray.count;
    }
    
    else{
        [self addScrollSubViews:_scrollView];
    }
    
    [self addTagScrollView];
    self.navigationController.navigationBarHidden=NO;
    
    _leftLabel.text=[NSString stringWithFormat:@"%.2f", _voice.duration];
    _rightLabel.text=@"-0.00";
    _slider.value=_slider.minimumValue;
    [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
    _pauseBtn.enabled=NO;

    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yy'-'MMM'-'dd'";
    _audioScriptLabel.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                            [formatter stringFromDate:_voice.createDate],
                            _voice.duration,
                            _voice.size/1024];
    [formatter release];
    
    _clipName.text=_voice.name;
    self.title=_voice.name;
}


- (void)dealloc{
    NSLog(@"voicemain dealloc");
    [self.pauseBtn release];
    [self.startBtn release];
    [self.tagScrollView release];
    [self.scrollView release];
    [self.mainImageView release];
    [self.imageCountLabel release];
    [self.mainTopView release];
    [self.leftLabel release];
    [self.rightLabel release];
    [self.slider release];
    [self.timer invalidate];
    _timer=nil;
    [self.audioScriptLabel release];
    [self.voice release];
    //[self.ipc release];
    //[self.layoutView release];
    [self.dirLabel release];
    [self.dirName release];
    
    if(_deleteSheet)
        [_deleteSheet release];
    if(_editSheet)
        [_editSheet release];
    if(_shareSheet)
        [_shareSheet release];
    
    [self.clipName release];
    
    [super dealloc];
}
 
- (void)viewDidUnload {
    [self setTagScrollView:nil];
    [self setStartBtn:nil];
    [self setPauseBtn:nil];
    [self setClipName:nil];
    [super viewDidUnload];
}

- (void)updatePlayerDuration{
    GlobalObj *globalObj=[GlobalObj globalObj];
        
    if([globalObj.player state] == PLAYER_STOP){
        [globalObj.player stop];
        [globalObj.player release];
        globalObj.player=nil;
        _slider.value=_slider.minimumValue;
        _rightLabel.text=@"-0.00";
        _pauseBtn.enabled=NO;
        [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
        [_timer invalidate];
        _timer=nil;
    }

    
    if([globalObj.player state]==PLAYER_PLAYING){
        float duration=[globalObj.player duration];
        float currentProgress=[globalObj.player estimateProgress];
        _rightLabel.text=[NSString stringWithFormat:@"-%.2f", duration*(1.0f-currentProgress)];
        _slider.value=currentProgress;
    }
    }

- (IBAction)play:(id)sender {
    GlobalObj *global=[GlobalObj globalObj];
   
    if(!global.player)
        global.player=[[DLPlayer alloc] initWithAudioFileURL:_voice.path];

    _pauseBtn.enabled=YES;
    if([global.player state] == PLAYER_PAUSE){
        [global.player resume];
        [_startBtn setImage:[UIImage imageNamed:@"stop_slideshow_btn.png"] forState:UIControlStateNormal];
    }

    else if([global.player state] == PLAYER_INIT||[global.player state] == PLAYER_STOP){
        [global.player play];
        [_startBtn setImage:[UIImage imageNamed:@"stop_slideshow_btn.png"] forState:UIControlStateNormal];
    }
    else if([global.player state] == PLAYER_PLAYING){
        [global.player stop];
        [global.player release];
        global.player=nil;
        _slider.value=_slider.minimumValue;
        _rightLabel.text=@"-0.00";
        _pauseBtn.enabled=NO;
        [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
        [_timer invalidate];
        _timer=nil;
    }
    
    if(!_timer){
        _timer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
        
    }
}

- (void)didBeginChangeProgress:(id)sender {
    if(_timer){
        [_timer invalidate];
        _timer=nil;
        
        [[GlobalObj globalObj].player stop];
        [[GlobalObj globalObj].player release];
        [GlobalObj globalObj].player=nil;
    }
}

- (void)didEndChangeProgress:(id)sender {
    
    GlobalObj *global=[GlobalObj globalObj];
    global.player=[[DLPlayer alloc] initWithAudioFileURL:_voice.path];
    
    [global.player setProgressWithFloat:((UISlider*)sender).value];
    
    
    _timer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
    
}



- (IBAction)pause:(id)sender {
    [[GlobalObj globalObj].player pause];
    [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
    _pauseBtn.enabled=NO;

}

- (IBAction)setProgress:(id)sender {
    if([[GlobalObj globalObj].player state]==PLAYER_PLAYING)
        [[GlobalObj globalObj].player setProgressWithFloat:_slider.value];
    else{
        _rightLabel.text=[NSString stringWithFormat:@"-%.2f", _voice.duration*(1.0-_slider.value)];
    }
}

- (IBAction)share:(id)sender {
    if(!_shareSheet)
        _shareSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
    
    [_shareSheet showInView:self.view];
}


- (void)_del{
    //Delete all images file with this voice
    NSFileManager *fm = [NSFileManager defaultManager];
    int i=0;
    for(i=0; i<_voice.imgArray.count; ++i){
        [fm removeItemAtPath:[_voice.imgArray objectAtIndex:i] error:nil];
    }
    
    SharedObj *obj=[SharedObj sharedObj];
    
    //Get voice index
    for(i=0; i<obj.voice.count; ++i){
        if([obj.voice objectAtIndex:i] == _voice)
            break;
    }
    int voiceIdx=i;
    
    
    //Refresh dir info's voice index
    for(NSString *dirName in obj.dirInfo.dirsMap){
        DirInfo *dirInfo=[obj.dirInfo.dirsMap objectForKey:dirName];
        int delIdx=-1;
        int _voiceIdx=0;
        for(i=0; i<dirInfo.voices.count; ++i){
            _voiceIdx=[[dirInfo.voices objectAtIndex:i] intValue];
            if(_voiceIdx == voiceIdx)
                delIdx=i;
            if(_voiceIdx > voiceIdx)
                [dirInfo.voices replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:_voiceIdx-1]];
        }
        
        if(delIdx>=0)
            [dirInfo.voices removeObjectAtIndex:delIdx];
    }
    
    
    //Refresh voice index in tag map
    for(NSString *tagName in obj.tag){
        NSMutableArray *array=[obj.tag objectForKey:tagName];
        int delIdx=-1;
        int _voiceIdx=0;
        for(i=0; i<array.count; ++i){
            _voiceIdx=[[array objectAtIndex:i] intValue];
            if(_voiceIdx == voiceIdx)
                delIdx=i;
            if(_voiceIdx > voiceIdx)
                [array replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:_voiceIdx-1]];
        }
        
        if(delIdx>=0)
            [array removeObjectAtIndex:delIdx];
    }
    
    //Delete voice file
    [fm removeItemAtPath:_voice.path error:nil];
    
    //Delete voice meta
    [obj.voice removeObjectAtIndex:voiceIdx];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)del:(id)sender {
    if(!_deleteSheet)
        _deleteSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    
    [_deleteSheet showInView:self.view];

}

- (IBAction)move:(id)sender {
    
    MoveView *moveView=[[MoveView alloc] initWithNibName:@"MoveView" bundle:nil];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:moveView];
    [navigationController.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];

    [self presentModalViewController:navigationController animated:YES];
    
    [moveView release];
    [navigationController release];
}
@end








