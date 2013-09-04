//
//  SideshowView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "SideshowView.h"
#import "SharedObj.h"
#import "VoiceInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "VoiceMainView.h"
#import "GlobalObj.h"
#import "AddPicView.h"

#define IMAGE_WIDTH     70
#define IMAGE_HEIGHT    62
#define PADDING         6

@interface SideshowView ()
@end

@implementation SideshowView

@synthesize voice=_voice;
@synthesize scrollView=_scrollView;
@synthesize timer=_timer;
@synthesize scrollViewPre=_scrollViewPre;
@synthesize label=_label;
@synthesize imageViews=_imageViews;
@synthesize imageViewsPre=_imageViewsPre;
@synthesize thumbBackground=_thumbBackground;
//@synthesize voiceBtn=_voiceBtn;
@synthesize trashBtn=_trashBtn;
@synthesize singTapOnListView=_singTapOnListView;
@synthesize singTapOnPreview=_singTapOnPreview;
@synthesize singTapOnFullScreenView=_singTapOnFullScreenView;
@synthesize doubleTapOnPreView=_doubleTapOnPreView;
@synthesize ipc=_ipc;
@synthesize layoutView=_layoutView;
@synthesize startBtn=_startBtn;
@synthesize pauseBtn=_pauseBtn;

-(void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
    _timer=nil;
    if([GlobalObj globalObj].player){
        [[GlobalObj globalObj].player stop];
        [[GlobalObj globalObj].player release];
        [GlobalObj globalObj].player=nil;
    }
    
}
- (void)dealloc{
    
    NSLog(@"slideshow dealloc");
    [self.startBtn release];
    [self.pauseBtn release];
    //[_voiceBtn removeFromSuperview];
    
    [self.singTapOnFullScreenView release];
    [self.singTapOnPreview release];
    [self.singTapOnListView release];
    [self.doubleTapOnPreView release];
    
    [self.imageViews release];
    [self.imageViewsPre release];
    [self.scrollView release];
    [self.timer release];
    [self.scrollViewPre release];
    [self.label release];
    
    [self.voice release];
    [self.thumbBackground release];
    [self.trashBtn release];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
            
            //delete image
        case 0:
            //reload data
        {
            __block int idx=0;
            __block CGRect frame=CGRectZero;
            __block CGRect framePre=CGRectZero;
            UIImageView *del=(UIImageView*)[_imageViews objectAtIndex:lastPage];
            UIImageView *delPre=(UIImageView*)[_imageViewsPre objectAtIndex:lastPage];
            
            frame=del.frame;
            framePre=delPre.frame;
            
            __block CGRect _frame=CGRectZero;
            __block CGRect _framePre=CGRectZero;
            int imgIdx=lastPage;
            
            [del removeFromSuperview];
            
            [UIView animateWithDuration:1.0f
                             animations:^{delPre.frame = CGRectZero;}
                             completion:^(BOOL finished){
                                 [delPre removeFromSuperview];
                                 
                                 //update offset
                                 xoffset-=_scrollViewPre.frame.size.width;
                                 offset-=IMAGE_WIDTH+10.0f;
                                 
                                 for(idx=lastPage+1; idx<_imageViews.count; ++idx){
                                     UIImageView *current=(UIImageView*)[_imageViews objectAtIndex:idx];
                                     _frame=current.frame;
                                     current.frame=frame;
                                     frame=_frame;
                                     
                                     UIImageView *currentPre=(UIImageView*)[_imageViewsPre objectAtIndex:idx];
                                     _framePre=currentPre.frame;
                                     currentPre.frame=framePre;
                                     framePre=_framePre;
                                 }
                                 
                                 
                                 [_imageViews removeObjectAtIndex:lastPage];
                                 [_imageViewsPre removeObjectAtIndex:lastPage];
                                 
                                 if(_imageViews.count==0){
                                     lastPage=-1;
                                     _trashBtn.hidden=YES;
                                 }
                                 else if(lastPage == _imageViews.count)
                                     lastPage=0;
                                 
                                 if(lastPage>=0){
                                     UIImageView *imageView=(UIImageView*)[_imageViews objectAtIndex:lastPage];
                                     UIColor *borderColor=borderColor = [UIColor redColor];
                                     imageView.layer.borderColor=borderColor.CGColor;
                                 }
                                 [_scrollViewPre setContentSize:CGSizeMake((size.width+2*PADDING) * _imageViews.count, size.height)];
                                 _label.text=[NSString stringWithFormat:@"%d/%d", lastPage+1, _imageViews.count];
                                 
                                 //delete image file
                                 NSFileManager *fm=[NSFileManager defaultManager];
                                 [fm removeItemAtPath:[_voice.imgArray objectAtIndex:imgIdx] error:nil];
                                 [_voice.imgArray removeObjectAtIndex:imgIdx];
                                 if(_voice.imgArray.count==0)
                                     _voice.imgIdx=-1;
                                 else
                                     _voice.imgIdx=0;
                                 
                                 lastImgCnt=_voice.imgArray.count;
                                 [SharedObj save];
                                 
                             }];
            break;
        }
            
            //cancel
        case 1:
            break;
        default:
            break;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo*)voice idx:(int)idx
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _voice=[voice retain];
        lastPage=idx;
        initIdx=idx;
        offset=10.0f;
        xoffset=0.0f;
        lastImgCnt=voice.imgArray.count;
        isInit=TRUE;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    if(_ipc){
        [_ipc release];
        [_layoutView release];
        _ipc=nil;
        _layoutView=nil;
    }
    if(isInit){
        [self _init];
        isInit=FALSE;
    }
    
    if(lastImgCnt!=_voice.imgArray.count){
        UIColor *borderColor=nil;
        int currentIdx=_imageViews.count;
        for(int i=currentIdx; i<_voice.imgArray.count; ++i){
            UIImage *_image=[[UIImage alloc] initWithContentsOfFile:[_voice.imgArray objectAtIndex:i]];
            UIImage *image = [GlobalObj reSizeImage:_image toSize:[UIScreen mainScreen].applicationFrame.size];

            [_image release];
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(offset,
                                                                                 10.0f,
                                                                                 IMAGE_WIDTH,
                                                                                 IMAGE_HEIGHT)];
            
            
            UIImageView *imageViewPre=[[UIImageView alloc] initWithFrame:CGRectMake(xoffset,
                                                                                    0,
                                                                                    size.width,
                                                                                    size.height)];
            
            xoffset += _scrollViewPre.frame.size.width;
            
            if(image.size.height > imageView.frame.size.height ||
               image.size.width > imageView.frame.size.width){
                imageView.contentMode=UIViewContentModeScaleToFill;
            }
            else
                imageView.contentMode=UIViewContentModeCenter;
            
            imageView.userInteractionEnabled=YES;
            imageView.image=image;
            
            imageViewPre.contentMode=UIViewContentModeScaleToFill;
            imageViewPre.clipsToBounds=YES;
            imageViewPre.userInteractionEnabled=YES;
            imageViewPre.image=image;
            
            if(i==currentIdx)
                borderColor = [UIColor redColor];
            else
                borderColor = [UIColor whiteColor];
            
            imageView.layer.borderColor= borderColor.CGColor;
            [imageView.layer setBorderWidth:1.0f];
            
            [_imageViews addObject:imageView];
            [_scrollView addSubview:imageView];
            
            [_imageViewsPre addObject:imageViewPre];
            [_scrollViewPre addSubview:imageViewPre];
            
            [imageView release];
            [imageViewPre release];
            //[image release];
            
            offset += IMAGE_WIDTH + 10.0f;
            
        }
        
        [_scrollViewPre setContentSize:CGSizeMake((size.width) * _voice.imgArray.count, size.height)];
        _scrollView.contentSize=CGSizeMake(offset+IMAGE_WIDTH,
                                           _scrollView.frame.size.height);
        
        if(lastPage>=0){
            UIImageView *imageView=(UIImageView*)[_imageViews objectAtIndex:lastPage];
            borderColor = [UIColor whiteColor];
            imageView.layer.borderColor=borderColor.CGColor;
        }
        
        lastPage=currentIdx;
        _label.text=[NSString stringWithFormat:@"%d/%d", lastPage+1, _imageViews.count];
        [_scrollViewPre scrollRectToVisible:((UIImageView*)[_imageViewsPre objectAtIndex:currentIdx]).frame animated:NO];
        [_scrollView scrollRectToVisible:((UIImageView*)[_imageViews objectAtIndex:currentIdx]).frame animated:NO];
        
        lastImgCnt=_voice.imgArray.count;
    }
    
    if(lastPage>=0)
        _trashBtn.hidden=NO;
    
    [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
    _pauseBtn.enabled=NO;
}


- (void)_init{
    _thumbBackground.image=[GlobalObj getImageFromFile:@"thumb_bckgd.png"];
    _trashBtn.hidden=NO;
    
    self.title=_voice.name;
    self.navigationController.navigationBar.hidden=NO;
    
    /*
     _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [_voiceBtn setImage:[UIImage imageNamed:@"audio_on_icon.png"] forState:UIControlStateNormal];
     [_voiceBtn sizeToFit];
     
     CGRect frame=_voiceBtn.frame;
     frame.origin.x = 270.0;
     frame.origin.y = 10.0;
     _voiceBtn.frame=frame;
     
     [self.navigationController.navigationBar addSubview:_voiceBtn];
     */
    
    _imageViews=[[NSMutableArray alloc] init];
    _imageViewsPre=[[NSMutableArray alloc] init];
    
    UIImage *image=nil;
    
    _scrollViewPre.pagingEnabled = YES;
    _scrollViewPre.showsHorizontalScrollIndicator = NO;
    _scrollViewPre.delegate = self;
    
    size = _scrollViewPre.frame.size;
    
    CGRect frame = CGRectMake(0,
                              _scrollViewPre.frame.origin.y,
                              (size.width),
                              size.height);
    _scrollViewPre.frame=frame;
    
    //NSLog(@"%f", frame.size.height);
    _scrollViewPre.clipsToBounds=NO;
    
    for(int idx=0; idx<_voice.imgArray.count; ++idx){
        UIImage  *_image=[[UIImage alloc] initWithContentsOfFile:[_voice.imgArray objectAtIndex:idx]];
        image = [GlobalObj reSizeImage:_image toSize:[UIScreen mainScreen].applicationFrame.size];
        
        [_image release];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(offset,
                                                                             10.0f,
                                                                             IMAGE_WIDTH,
                                                                             IMAGE_HEIGHT)];
        
        
        UIImageView *imageViewPre=[[UIImageView alloc] initWithFrame:CGRectMake(xoffset,
                                                                                0,
                                                                                size.width,
                                                                                size.height)];
        
        xoffset += _scrollViewPre.frame.size.width;
        
        if(image.size.height > imageView.frame.size.height ||
           image.size.width > imageView.frame.size.width){
            imageView.contentMode=UIViewContentModeScaleToFill;
        }
        else
            imageView.contentMode=UIViewContentModeCenter;
        
        imageView.userInteractionEnabled=YES;
        imageView.image=image;
        
        imageViewPre.contentMode=UIViewContentModeScaleToFill;
        imageViewPre.clipsToBounds=YES;
        imageViewPre.userInteractionEnabled=YES;
        imageViewPre.image=image;
        
        
        UIColor *borderColor=nil;
        if(idx==initIdx)
            borderColor = [UIColor redColor];
        else
            borderColor = [UIColor whiteColor];
        
        imageView.layer.borderColor= borderColor.CGColor;
        [imageView.layer setBorderWidth:1.0f];
        
        [_imageViews addObject:imageView];
        [_scrollView addSubview:imageView];
        
        [_imageViewsPre addObject:imageViewPre];
        [_scrollViewPre addSubview:imageViewPre];
        
        [imageView release];
        [imageViewPre release];
        //[image release];
        
        offset += IMAGE_WIDTH + 10.0f;
        
    }
    
    [_scrollViewPre setContentSize:CGSizeMake((size.width) * _voice.imgArray.count, size.height)];
    _scrollView.contentSize=CGSizeMake(offset+IMAGE_WIDTH,
                                       _scrollView.frame.size.height);
    
    UIImageView *imagePre=[_imageViewsPre objectAtIndex:initIdx];
    [_scrollViewPre scrollRectToVisible:imagePre.frame animated:YES];
    
    
    _label.text=[NSString stringWithFormat:@"%d/%d", lastPage+1, _imageViews.count];
    _singTapOnPreview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_singTapOnPreview setNumberOfTapsRequired:1];
    [_scrollViewPre addGestureRecognizer:_singTapOnPreview];
    
    _singTapOnListView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_singTapOnListView setNumberOfTapsRequired:1];
    [_scrollView addGestureRecognizer:_singTapOnListView];
    
    _doubleTapOnPreView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [_doubleTapOnPreView setNumberOfTapsRequired:2];
    [_scrollViewPre addGestureRecognizer:_doubleTapOnPreView];
    
    [_singTapOnPreview requireGestureRecognizerToFail:_doubleTapOnPreView];
    
    
    isFullScreen=FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
}


- (void)appHasGoneInBackground{
    self.navigationController.navigationBar.hidden=NO;
}

- (void) handleDoubleTap:(UITapGestureRecognizer *) gestureRecognizer{
    
    if(isFullScreen){
        [UIView animateWithDuration:0.1f animations:^{
            UIImageView *imageView=[_imageViewsPre objectAtIndex:fullScreenIdx];
            CGRect theFrame = imageView.frame;
            theFrame.size.height= size.height;
            imageView.frame = theFrame;
        }completion:^(BOOL finished){
            isFullScreen=NO;
            _scrollViewPre.scrollEnabled=YES;
        }];
        
        return;
    }
    
    self.navigationController.navigationBar.hidden=YES;
    CGPoint pt=[gestureRecognizer locationInView:_scrollViewPre];
    
    for(int i=0; i<_imageViewsPre.count; ++i){
        UIImageView *imageView=[_imageViewsPre objectAtIndex:i];
        CGPoint _pt=[_scrollViewPre convertPoint:pt toView:imageView];
        if(_pt.x>=0.0f && _pt.x<=imageView.frame.size.width){
            // Get clicked image
            CGRect appFrame=[UIScreen mainScreen].applicationFrame;
            [UIView animateWithDuration:0.1f
                             animations:^{
                                 CGRect theFrame = imageView.frame;
                                 theFrame.size.height= appFrame.size.height;
                                 imageView.frame = theFrame;
                             }
                             completion:^(BOOL finished){
                                 isFullScreen=YES;
                                 _scrollViewPre.scrollEnabled=NO;
                                 fullScreenIdx=i;
                                 _trashBtn.hidden=YES;
                             }];
            break;
        }
    }
    
}

- (void) handleSingleTap:(UITapGestureRecognizer *) gestureRecognizer{
    if(isFullScreen){
        _trashBtn.hidden=YES;
    }
    
    if(gestureRecognizer.view == _scrollViewPre){
        CATransition *animation=[CATransition animation];
        animation.timingFunction=[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionDefault];
        animation.type=kCATransitionMoveIn;
        animation.subtype=kCATransitionFromTop;
        animation.duration=0.5f;
        BOOL value=self.navigationController.navigationBar.hidden?NO:YES;
        self.navigationController.navigationBar.hidden=value;
        if(!isFullScreen)
            _trashBtn.hidden=value;
        [self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
        
    }
    
    else if(gestureRecognizer.view == _scrollView){
        CGPoint pt=[gestureRecognizer locationInView:_scrollView];
        
        for(int i=0; i<_imageViews.count; ++i){
            UIImageView *imageView=[_imageViews objectAtIndex:i];
            CGPoint _pt=[_scrollView convertPoint:pt toView:imageView];
            if(_pt.x>=0.0f && _pt.x<=imageView.frame.size.width){
                
                // Get clicked image
                UIColor *borderColor = [UIColor redColor];
                imageView.layer.borderColor=borderColor.CGColor;
                
                if(lastPage>=0){
                    UIImageView *imageView=(UIImageView*)[_imageViews objectAtIndex:lastPage];
                    borderColor = [UIColor whiteColor];
                    imageView.layer.borderColor=borderColor.CGColor;
                }
                
                lastPage=i;
                
                _label.text=[NSString stringWithFormat:@"%d/%d", i+1, _imageViews.count];
                UIImageView *imagePre=[_imageViewsPre objectAtIndex:i];
                [_scrollViewPre scrollRectToVisible:imagePre.frame animated:YES];
                break;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page = (int)(_scrollViewPre.contentOffset.x / _scrollViewPre.bounds.size.width);
    
    if(page == lastPage)
        return;
    
    _label.text=[NSString stringWithFormat:@"%d/%d", page+1, _imageViews.count];
    
    UIImageView *imageView=(UIImageView*)[_imageViews objectAtIndex:page];
    UIColor *borderColor = [UIColor redColor];
    imageView.layer.borderColor=borderColor.CGColor;
    
    if(lastPage>=0){
        UIImageView *imageView=(UIImageView*)[_imageViews objectAtIndex:lastPage];
        borderColor = [UIColor whiteColor];
        imageView.layer.borderColor=borderColor.CGColor;
    }
    
    lastPage=page;
    [_scrollView scrollRectToVisible:imageView.frame animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"slideshow memory warning");
    if ([self.view window] == nil){
        self.imageViews=nil;
        self.imageViewsPre=nil;
        self.view = nil;
    }
    
    
}


- (void)viewDidUnload {
    [self setTrashBtn:nil];
    [self setStartBtn:nil];
    [self setPauseBtn:nil];
    [super viewDidUnload];
}
- (IBAction)takePic:(id)sender {
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
    
    
    //[self presentModalViewController:_ipc animated:YES];
    
    
    [self presentViewController:_ipc animated:YES completion:^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        
    }];
    
}

- (void)updatePlayerDuration{
    GlobalObj *globalObj=[GlobalObj globalObj];
    if([globalObj.player state] == PLAYER_STOP){
        [globalObj.player stop];
        [globalObj.player release];
        globalObj.player=nil;
        _pauseBtn.enabled=NO;
        [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
        
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
        _pauseBtn.enabled=NO;
        [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
        [_timer invalidate];
        _timer=nil;
    }
    
    if(!_timer){
        _timer=[NSTimer  scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updatePlayerDuration) userInfo:nil repeats:YES];
        
    }
}


- (IBAction)pause:(id)sender {
    [[GlobalObj globalObj].player pause];
    [_startBtn setImage:[UIImage imageNamed:@"play_slideshow_btn.png"] forState:UIControlStateNormal];
    _pauseBtn.enabled=NO;
}
- (IBAction)deleteImage:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Image" otherButtonTitles:nil];
    
    [sheet showInView:self.view];
}
@end






