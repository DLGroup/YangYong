//
//  MoveView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/1/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MoveView.h"
#import "SharedObj.h"
#import "DirInfo.h"
#import "VoiceMainView.h"
#import "VoiceInfo.h"
#import "FolderNew.h"
@interface MoveView ()

@end

@implementation MoveView

@synthesize tableView=_tableView;
@synthesize imageView=_imageView;

- (void)dealloc{
    NSLog(@"moveview dealloc");
    _tableView=nil;
    _imageView=nil;
}


- (void)done{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        rightBarBtnItem.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem=rightBarBtnItem;
        
        lastDirCount=[SharedObj sharedObj].dirInfo.subDirs.count;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"Move";
    
    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    
    _imageView.clipsToBounds=YES;
    VoiceInfo *voice=mainView.voice;
    if(voice.imgIdx >= 0){
        UIImage *image=[[UIImage alloc]initWithContentsOfFile:[voice.imgArray objectAtIndex:voice.imgIdx]];
        _imageView.image=image;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[SharedObj sharedObj].dirInfo.subDirs count]+1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellId=@"BaseCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderListCell" owner:self options:nil] lastObject];
    }
    
    UILabel *folderNameLabel=(UILabel*)[cell viewWithTag:101];
    UIView *acessView=[cell viewWithTag:103];
    UILabel *voiceCntLabel=(UILabel*)[cell viewWithTag:102];
    UIView *imageView=[cell viewWithTag:104];

    //Add folder
    if(indexPath.row==0){
        folderNameLabel.text=@"New Folder";
        acessView.hidden=NO;
        imageView.hidden=YES;
        voiceCntLabel.hidden=YES;
        folderNameLabel.font=[UIFont italicSystemFontOfSize:14.0f];

        return cell;
    }
    else{
        acessView.hidden=YES;
        imageView.hidden=NO;
        voiceCntLabel.hidden=NO;
        folderNameLabel.font=[UIFont systemFontOfSize:14.0f];
    }
    folderNameLabel.text=[[SharedObj sharedObj].dirInfo.subDirs objectAtIndex:indexPath.row-1];
    
    DirInfo *dirInfo=[[SharedObj sharedObj].dirInfo.dirsMap objectForKey:folderNameLabel.text];
    voiceCntLabel.text=[NSString stringWithFormat:@"%d", dirInfo.voices.count];
    
    CGFloat _width = [voiceCntLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f]].width;
    
    CGRect frame=voiceCntLabel.frame;
    frame.size.width -= (frame.size.width-_width);
    frame.size.width += 15.0f;
    voiceCntLabel.frame=frame;
    voiceCntLabel.layer.cornerRadius=9.0f;


    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIImageView *customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clip_sepector.png"]];
    return customView;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor=[UIColor lightGrayColor];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0){
        FolderNew *folderNew=[[FolderNew alloc] initWithNibName:@"FolderNew" bundle:nil lastFolderName:nil];
        [self.navigationController pushViewController:folderNew animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

        return;
    }
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UILabel *folderNameLabel=(UILabel*)[cell viewWithTag:101];

    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    
    //move to same folder, do nothing
    if([folderNameLabel.text isEqualToString:mainView.dirName]){
        [self done];
        return;
    }
    
    SharedObj *obj=[SharedObj sharedObj];
    int i=0;
    
    //Get voice index
    for(i=0; i<obj.voice.count; ++i){
        if([obj.voice objectAtIndex:i] == mainView.voice)
            break;
    }
    int voiceIdx=i;
    
    mainView.voice.dir=folderNameLabel.text;

    //Delete voice index in laste folder
    DirInfo *lastDirInfo=[obj.dirInfo.dirsMap objectForKey:mainView.dirName];
    int _voiceIdx=-1;
    for(i=0; i<lastDirInfo.voices.count; ++i){
         _voiceIdx=[[lastDirInfo.voices objectAtIndex:i] intValue];
        if(_voiceIdx == voiceIdx){
            [lastDirInfo.voices removeObjectAtIndex:i];
            break;
        }
    }
    
    //Add to selected folder
    DirInfo *currentDirInfo=[obj.dirInfo.dirsMap objectForKey:folderNameLabel.text];
    [currentDirInfo.voices addObject:[NSNumber numberWithInt:voiceIdx]];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [mainView.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated{
    if(lastDirCount != [SharedObj sharedObj].dirInfo.subDirs.count){
        UINavigationController *nav=(UINavigationController*)self.presentingViewController;
        VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
        
        SharedObj *obj=[SharedObj sharedObj];
        int i=0;
        
        //Get voice index
        for(i=0; i<obj.voice.count; ++i){
            if([obj.voice objectAtIndex:i] == mainView.voice)
                break;
        }
        int voiceIdx=i;
        
        NSArray *array = [SharedObj sharedObj].dirInfo.subDirs;
        mainView.voice.dir=[array lastObject];
        
        //Delete voice index in laste folder
        DirInfo *lastDirInfo=[obj.dirInfo.dirsMap objectForKey:mainView.dirName];
        int _voiceIdx=-1;
        for(i=0; i<lastDirInfo.voices.count; ++i){
            _voiceIdx=[[lastDirInfo.voices objectAtIndex:i] intValue];
            if(_voiceIdx == voiceIdx){
                [lastDirInfo.voices removeObjectAtIndex:i];
                break;
            }
        }
        
        //Add to selected folder
        DirInfo *currentDirInfo=[obj.dirInfo.dirsMap objectForKey:mainView.voice.dir];
        [currentDirInfo.voices addObject:[NSNumber numberWithInt:voiceIdx]];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [mainView.navigationController popViewControllerAnimated:YES];
        }];
    }
}
@end






