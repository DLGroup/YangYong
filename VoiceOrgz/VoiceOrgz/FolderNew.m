//
//  FolderNew.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "FolderNew.h"
#import "DirInfo.h"
#import "SharedObj.h"
#import "VoiceInfo.h"

@interface FolderNew ()

@end

@implementation FolderNew
@synthesize textField=_textField;
@synthesize lastFolderName=_lastFolderName;
@synthesize alertView=_alertView;


- (void)dealloc{
    NSLog(@"foldernew dealloc");
    _textField=nil;
    _lastFolderName=nil;
    _alertView=nil;
}

- (void)cancel{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    NSString *newFolderName=_textField.text;
    NSMutableDictionary *map=[SharedObj sharedObj].dirInfo.dirsMap;
    NSMutableArray *array=[SharedObj sharedObj].dirInfo.subDirs;

    //Empty text
    if([newFolderName isEqualToString:@""]){
        return;
    }
    
    //Process same folder name
    else if([map objectForKey:newFolderName]){
        self.navigationItem.leftBarButtonItem.enabled=NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;
        [self showAlert];
        [self performSelector:@selector(hiddenAlert) withObject:nil afterDelay:0.5];
        return;
    }
    
    //Create a new folder
    else if(!_lastFolderName){
        [array addObject:newFolderName];
        
        DirInfo *info=[[DirInfo alloc] initWithParent:newFolderName];
        [map setObject:info forKey:newFolderName];
    }
    
    //Change folder name
    else if(![newFolderName isEqualToString:_lastFolderName]){
        DirInfo *dirInfo=[map objectForKey:_lastFolderName];
        dirInfo.parent=newFolderName;
        
        [map setObject: dirInfo forKey: newFolderName];
        [map removeObjectForKey: _lastFolderName];
        
        int idx=[array indexOfObject:_lastFolderName];
        
        [array replaceObjectAtIndex:idx withObject:newFolderName];
        
        //Refresh voice meta's dir info
        for(int i=0; i<dirInfo.voices.count; ++i){
            VoiceInfo *voice=[[SharedObj sharedObj].voice objectAtIndex:
                              [[dirInfo.voices objectAtIndex:i] intValue]];
            voice.dir=newFolderName;
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)valueChanged:(id)sender {
    if([_textField.text isEqualToString:@""])
        self.navigationItem.rightBarButtonItem.enabled=NO;
    else
        self.navigationItem.rightBarButtonItem.enabled=YES;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lastFolderName:(NSString *)lastFolderName
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
        
        _lastFolderName=lastFolderName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _textField.text=_lastFolderName;
    self.navigationItem.rightBarButtonItem.enabled=NO;

    [_textField becomeFirstResponder];
    
    if(_lastFolderName)
        self.title=@"Rename Folder";
    else
        self.title=@"New Folder";

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
