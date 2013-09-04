//
//  TagNew.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TagNew.h"
#import "SharedObj.h"
#import "VoiceInfo.h"
#import "VoiceTag.h"

@interface TagNew ()

@end

@implementation TagNew
@synthesize textField=_textField;
@synthesize lastTagName=_lastTagName;
@synthesize alertView=_alertView;
- (void)dealloc{
    NSLog(@"tagnew dealloc");
    _textField=nil;
    _lastTagName=nil;
    _alertView=nil;
}

- (void)cancel{
    if(self.navigationController.viewControllers.count==2)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void)hiddenAlert{
    CATransition *animation=[CATransition animation];
    animation.timingFunction=[CAMediaTimingFunction
                              functionWithName:kCAMediaTimingFunctionDefault];
    animation.type=kCATransitionMoveIn;
    animation.subtype=kCATransitionFromBottom;
    animation.duration=0.5f;
    _alertView.hidden=YES;
    [_alertView.layer addAnimation:animation forKey:nil];
    self.navigationItem.leftBarButtonItem.enabled=YES;
    self.navigationItem.rightBarButtonItem.enabled=YES;
}


- (void)save{
    NSString *newTagName=_textField.text;
    NSMutableDictionary *map=[SharedObj sharedObj].tag;
    
    //Empty text
    if([newTagName isEqualToString:@""]){
        return;
    }
    
    //Process same tag name
    else if([map objectForKey:newTagName]){
        self.navigationItem.leftBarButtonItem.enabled=NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;
        [self showAlert];
        [self performSelector:@selector(hiddenAlert) withObject:nil afterDelay:0.5];
        return;
    }
    
    //Create a new tag
    else if(!_lastTagName){
        [map setObject:[[NSMutableArray alloc] init] forKey:newTagName];
        if(self.navigationController.viewControllers.count==2){
            VoiceTag *voiceTag=[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            voiceTag.tagName=newTagName;
        }
    }
    
    //Change tag name
    else if(![newTagName isEqualToString:_lastTagName]){
        NSMutableArray *array=[[SharedObj sharedObj].tag objectForKey:_lastTagName];
        [[SharedObj sharedObj].tag setObject:array forKey:newTagName];
        [[SharedObj sharedObj].tag removeObjectForKey:_lastTagName];
        
        //update voice tags
        for(int i=0; i<array.count; ++i){
            int voiceIdx=[[array objectAtIndex:i] intValue];
            VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex:voiceIdx];
            [info.tag replaceObjectAtIndex:[info.tag indexOfObject:_lastTagName] withObject:newTagName];
        }
    }
    
    if(self.navigationController.viewControllers.count==2)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lastTagName:(NSString *)lastTagName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *leftBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        leftBtn.tintColor=[UIColor blackColor];
        self.navigationItem.leftBarButtonItem=leftBtn;
        UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        rightBtn.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem=rightBtn;
        
        _lastTagName=lastTagName;
    }
    return self;
}

- (IBAction)valueChanged:(id)sender {
    if([_textField.text isEqualToString:@""])
        self.navigationItem.rightBarButtonItem.enabled=NO;
    else
        self.navigationItem.rightBarButtonItem.enabled=YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_textField becomeFirstResponder];
    _textField.text=_lastTagName;
    self.navigationItem.rightBarButtonItem.enabled=NO;

    if(_lastTagName)
        self.title=@"Rename Tag";
    else
        self.title=@"New Tag";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextField:nil];
    [self setAlertView:nil];
    [super viewDidUnload];
}
@end
