//
//  AddPicView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 7/23/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AddPicView.h"
#import "VoiceInfo.h"
#import "GlobalObj.h"
#import <sys/time.h>
#import "VoiceMainView.h"
#import "SideshowView.h"

#define MAX_COUNT 9
#define IMAGE_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images"]

static NSString* defaultName(NSString *voiceName)
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    NSString *dateString=[NSString stringWithFormat:@"%@_%ld%d", voiceName, time.tv_sec, time.tv_usec];
    
	return [dateString stringByAppendingString:@".jpg"];
}
@interface AddPicView ()

@end

@implementation AddPicView

@synthesize imagePreView=_imagePreView;
@synthesize label=_label;
@synthesize voice=_voice;
@synthesize ipc=_ipc;
@synthesize imgArray=_imgArray;
@synthesize pictureView=_pictureView;
@synthesize alertView=_alertView;
@synthesize cameraBtn=_cameraBtn;
- (void)dealloc{
    NSLog(@"addpicview dealloc");
    [self.imagePreView release];
    [self.label release];
    [self.imgArray release];
    [self.pictureView release];
    [self.alertView release];
    [self.cameraBtn release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipc:(UIImagePickerController *)ipc voice:(VoiceInfo *)voice
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _voice=voice;
        imageCount=0;
        _ipc=ipc;
        _imgArray=[[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateImage{
    _label.text=[NSString stringWithFormat:@"%d", imageCount];
    _imagePreView.image=[_imgArray objectAtIndex:imageCount-1];
    _pictureView.hidden=NO;
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [_imgArray addObject:image];
    
    imageCount++;
    [self updateImage];
}

- (void)viewDidUnload {
    [self setImagePreView:nil];
    [self setLabel:nil];
    [self setPictureView:nil];
    [self setAlertView:nil];
    [self setCameraBtn:nil];
    [super viewDidUnload];
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


- (IBAction)takePic:(id)sender {
    if(_voice.imgArray.count+imageCount < MAX_COUNT){
        [_ipc takePicture];
    }
    else{
        _cameraBtn.enabled=NO;
        [self showAlert];
        [self performSelector:@selector(hiddenAlert) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)controller:(id)sender{
    NSString *fileName=[_voice.path lastPathComponent];
    NSString *voiceName=[fileName substringToIndex:fileName.length-4];
    for(int i=0; i<_imgArray.count; ++i){
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        NSString *path=[NSString stringWithFormat:@"%@/%@", IMAGE_FOLDER, defaultName(voiceName)];
        
        //max compression
        NSData *data=UIImageJPEGRepresentation([_imgArray objectAtIndex:i], 1.0f);
        [data writeToFile:path atomically:NO];
        [_voice.imgArray addObject:path];
        [pool drain];
    }
    
    if(_voice.imgArray.count>0)
        _voice.imgIdx=0;
    
    [_ipc dismissViewControllerAnimated:YES completion:^(void){}];
}

@end







