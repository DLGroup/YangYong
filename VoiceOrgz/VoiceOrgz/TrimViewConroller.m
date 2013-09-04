//
//  TrimViewConroller.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 4/15/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "TrimViewConroller.h"
#import "VoiceInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "SharedObj.h"
#import "GlobalObj.h"
#import "DLPlayer.h"

#define MAX_RENDER_POINTS   700
#define PADDING 23

@interface TrimViewConroller ()
@end

@implementation TrimViewConroller
@synthesize voice=_voice;
@synthesize waveView=_waveView;
@synthesize mainImageView=_mainImageView;
@synthesize audioScriptLabel=_audioScriptLabel;
@synthesize imageCountLabel=_imageCountLabel;
@synthesize waveImage=_waveImage;
@synthesize samples=_samples;
@synthesize queue=_queue;
@synthesize indicator=_indicator;
@synthesize trimView=_trimView;
@synthesize rightView=_rightView;
@synthesize leftView=_leftView;
@synthesize playBtn=_playBtn;
@synthesize trimBtn=_trimBtn;
@synthesize dirLabel=_dirLabel;
@synthesize dirName=_dirName;
@synthesize tagScrollView=_tagScrollView;

- (void)dealloc{
    NSLog(@"trimview dealloc");
    _waveImage=nil;
    _samples=nil;
    _queue=nil;
    _dirName=nil;
}

-(void)prepareImage{
    
    UIGraphicsBeginImageContextWithOptions(_waveView.frame.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    float viewHeight=_waveView.frame.size.height;
    float viewWidth=_waveView.frame.size.width;
    
    CGContextMoveToPoint(context, 0.0f, viewHeight/2.0f);
    CGContextAddLineToPoint(context, viewWidth, viewHeight/2.0f);
    
    float xOffset=0.0f;
    float step=viewWidth/_samples.count;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint (path, NULL, 0.0f, viewHeight/2.0f);
    for(int idx=0; idx<_samples.count; ++idx){
        float value=[[_samples objectAtIndex:idx] floatValue];
        float yOffset=0.0f;
        
        yOffset=(1.0f-value)*(viewHeight/2.0f);
        
        CGPathAddLineToPoint (path, NULL, xOffset, yOffset);
        xOffset+=step;
    }
    
    
    CGMutablePathRef _path = CGPathCreateMutable();
    xOffset=0.0f;
    CGPathMoveToPoint (path, NULL, 0.0f, viewHeight/2.0f);
    for(int idx=0; idx<_samples.count; ++idx){
        float value=[[_samples objectAtIndex:idx] floatValue];
        float yOffset=0.0f;
        
        yOffset=(value+1.0f)*(viewHeight/2.0f);
        CGPathAddLineToPoint (path, NULL, xOffset, yOffset);
        xOffset+=step;
    }
    
    CGContextAddPath(context, path);
    CGContextAddPath(context, _path);
    CGPathRelease(path);
    CGPathRelease(_path);
    [[UIColor colorWithRed:0.28f green:0.85f blue:0.55f alpha:1.0f] setStroke];
    CGContextStrokePath(context);
    
    
    _waveImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)prepareSamples{
    
    GlobalObj *globalObj=[GlobalObj globalObj];
    _samples=globalObj.player.samples;
    
    if(_samples.count > MAX_RENDER_POINTS){
        _samples=[[NSMutableArray alloc] init];
        
        int pointsInPerRenderPoints=globalObj.player.samples.count/MAX_RENDER_POINTS;
        if(pointsInPerRenderPoints <= 0)
            pointsInPerRenderPoints=1;
        
        srand(time(0));
        for(int idx=0; idx<globalObj.player.samples.count; idx+=pointsInPerRenderPoints){
            
            int i = rand()%pointsInPerRenderPoints;
            if(i+idx<globalObj.player.samples.count)
                i+=idx;
            else
                i=idx;
            
            float value=[[globalObj.player.samples objectAtIndex:i] floatValue];
            [(NSMutableArray*)_samples addObject:[NSNumber numberWithFloat:value]];
        }
    }
}


- (IBAction)play:(id)sender{
    
    float leftX=_leftView.frame.origin.x;
    float rightX=_rightView.frame.origin.x;
    leftX += _trimView.frame.size.width/2.0-PADDING;
    rightX -= PADDING;
    
    start=leftX/_waveView.frame.size.width;
    end=rightX/_waveView.frame.size.width;

    NSLog(@"%f,%f", start, end);
    GlobalObj *globalObj=[GlobalObj globalObj];
    [globalObj.player setStartPostion:start endPoint:end];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 1:
            break;
        case 0:
        {
            float leftX=_leftView.frame.origin.x;
            float rightX=_rightView.frame.origin.x;
            leftX += _trimView.frame.size.width/2.0-PADDING;
            rightX -= PADDING;
            
            start=leftX/_waveView.frame.size.width;
            end=rightX/_waveView.frame.size.width;
            
            
            GlobalObj *globalObj=[GlobalObj globalObj];
            [globalObj.player createSegmentAudio:start endPoint:end withReplace:YES];
            
            _voice.createDate=[NSDate date];
            _voice.size=_voice.size*(end-start);
            _voice.duration=_voice.duration*(end-start);
            
            globalObj.player=[[DLPlayer alloc] initWithAudioFileURL:_voice.path];
            
            
            //reload data
            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
            formatter.dateFormat=@"yy'-'MMM'-'dd'";
            _audioScriptLabel.text=[NSString stringWithFormat:@"%@, %.2fS, %lldKB",
                                    [formatter stringFromDate:_voice.createDate],
                                    _voice.duration,
                                    _voice.size/1024];
            
            _indicator.hidden=NO;
            _waveView.hidden=YES;
            _rightView.hidden=YES;
            _leftView.hidden=YES;
            _trimBtn.enabled=NO;
            _playBtn.enabled=NO;
            
            NSBlockOperation *operation=[[NSBlockOperation alloc] init];
            
            __weak NSBlockOperation *weakOperation=operation;
            [operation addExecutionBlock:^(void){
                [[GlobalObj globalObj].player caculateSamples:weakOperation];
                [self prepareSamples];
                [self prepareImage];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                    _waveView.image=_waveImage;
                    
                    _leftView.frame=leftRect;
                    _rightView.frame=rightRect;
                    
                    _indicator.hidden=YES;
                    _waveView.hidden=NO;
                    _rightView.hidden=NO;
                    _leftView.hidden=NO;
                    _trimBtn.enabled=YES;
                    _playBtn.enabled=YES;
                }];
            }];
            
            [_queue addOperation:operation];
            
        }
            break;
    }
    
}

- (IBAction)trim:(id)sender {
    
    UIActionSheet *menu=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Trim" otherButtonTitles:nil, nil];

    [menu showInView:self.view];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil voice:(VoiceInfo *)voice dirName:(NSString *)dirName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _voice=voice;
        _dirName=[dirName copy];
    }
    return self;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    _dirLabel.text=[NSString stringWithFormat:@"VoiceOrgz-%@", _dirName];
    self.title=@"Trim";
    
    [_mainImageView.layer setMasksToBounds:YES];
    [_mainImageView.layer setCornerRadius:11.0f];
    
    [self addTagScrollView];
    UIImage *image=nil;
    //BOOL userImage=NO;
    if(_voice.imgIdx >= 0){
        image=[UIImage imageWithContentsOfFile:[_voice.imgArray objectAtIndex:_voice.imgIdx]];
        //if(image)
        //    userImage=YES;
    }
    
    //if(!userImage)
    //    image=[GlobalObj getImageFromFile:@"red_light.png"];
    
    _mainImageView.image=image;
    
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
    
    
    [_indicator startAnimating];
    _trimView.backgroundColor=[UIColor colorWithPatternImage:[GlobalObj getImageFromFile:@"toolset_background.png"]];
    _trimView.layer.cornerRadius = 8.0f;
    _trimView.layer.masksToBounds = YES;
    
    _waveView.backgroundColor=[UIColor blackColor];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(panHander:)];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(panHander:)];

    [_leftView addGestureRecognizer:leftPan];
    [_rightView addGestureRecognizer:rightPan];
    
    _queue=[[NSOperationQueue alloc] init];
    
    NSBlockOperation *operation=[[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOperation=operation;
    [operation addExecutionBlock:^(void){
        [GlobalObj globalObj].player=[[DLPlayer alloc] initWithAudioFileURL:_voice.path];

        [[GlobalObj globalObj].player caculateSamples:weakOperation];
        [self prepareSamples];
        [self prepareImage];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
            _waveView.image=_waveImage;
            
            _indicator.hidden=YES;
            _waveView.hidden=NO;
            _rightView.hidden=NO;
            _leftView.hidden=NO;
            _trimBtn.enabled=YES;
            _playBtn.enabled=YES;
        }];
    }];
    
    [_queue addOperation:operation];
    
    leftRect=_leftView.frame;
    rightRect=_rightView.frame;
}

- (void)panHander:(UIPanGestureRecognizer *)pan

{
    CGPoint pt=[pan locationInView:_trimView];
    if (pan.state==UIGestureRecognizerStateBegan){
        ptBegin=pt;
        
    }else if (pan.state==UIGestureRecognizerStateChanged){
        UIView *view=[pan view];
        CGRect frame=view.frame;
        
        BOOL canDrag=NO;
        float X=pt.x-ptBegin.x+frame.origin.x;

        if(view == _leftView){
            if(-_trimView.frame.size.width/2.0+PADDING<=X && X<=0.0)
                canDrag=YES;
        }
        else if(view == _rightView){
            if(_trimView.frame.size.width/2.0<=X && X<=_trimView.frame.size.width-PADDING)
                canDrag=YES;
        }
        
        if(canDrag){
            frame.origin.x += pt.x-ptBegin.x;
            view.frame=frame;
        }
        
        ptBegin=pt;
    }else if (pan.state==UIGestureRecognizerStateEnded){
        
        // cut
    }
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [_queue cancelAllOperations];
    [[GlobalObj globalObj].player stop];
    [GlobalObj globalObj].player=nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDirLabel:nil];
    [self setTagScrollView:nil];
    [super viewDidUnload];
}
@end
