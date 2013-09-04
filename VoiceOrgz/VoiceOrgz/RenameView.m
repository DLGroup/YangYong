//
//  RenameView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 9/3/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "RenameView.h"
#import "VoiceMainView.h"
#import "VoiceInfo.h"

@interface RenameView ()

@end

@implementation RenameView

@synthesize textField=_textField;

- (void)cancel{
   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save{
    NSString *newName=_textField.text;
    
    //Empty text
    if([newName isEqualToString:@""]){
        return;
    }
    
    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    VoiceInfo *voice=mainView.voice;
    voice.name=newName;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    VoiceInfo *voice=mainView.voice;
    _textField.text=voice.name;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextField:nil];
    [super viewDidUnload];
}
- (IBAction)valueChanged:(id)sender {
    if([_textField.text isEqualToString:@""])
        self.navigationItem.rightBarButtonItem.enabled=NO;
    else
        self.navigationItem.rightBarButtonItem.enabled=YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [_textField becomeFirstResponder];
}
@end
