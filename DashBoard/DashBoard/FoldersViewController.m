//
//  FoldersViewController.m
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "FoldersViewController.h"
#import "FolderCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundData.h"


#define CELLHEIGHT 67.0f

@interface FoldersViewController ()
{
    NSUInteger selectedSection;
    BOOL inserting;
    SoundData *soundData;
    NSMutableString *soundName;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//animation property
@property (strong, nonatomic) IBOutlet UIView *recAnimView;
@property (strong, nonatomic) IBOutlet UIView *stopAndPauseAnimView;
@property (strong, nonatomic) IBOutlet UIView *recMaskAnimView;

- (IBAction)stop:(id)sender;
- (IBAction)record:(id)sender;

@end

@implementation FoldersViewController

@synthesize tableView = _tableView;
@synthesize recAnimView = _recAnimView;
@synthesize stopAndPauseAnimView = _stopAndPauseAnimView;
@synthesize recMaskAnimView = _recMaskAnimView;

//need delete after audio things done
static NSUInteger fileNumber = 0;

#pragma mark - Class method

+ (void) setFolderName:(NSString *)name
{
    folderName = [[NSString alloc] initWithFormat:@"%@", name];
}

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = folderName;
        sectionCounts = 0;
        selectedSection = -1;
        inserting = TRUE;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //...singleton -- sound Of global data
    soundData = [SoundData sharedSoundData];
    soundName = [[NSMutableString alloc] init];
    //...
    [self recAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"disappear");
    [_recAnimView.layer setPosition:CGPointMake(_recAnimView.layer.position.x, self.view.frame.size.height+_recAnimView.frame.size.height/2)];
    [_recMaskAnimView.layer setPosition:CGPointMake(-_recMaskAnimView.frame.size.width/2, _recMaskAnimView.layer.position.y)];
    [_recMaskAnimView setHidden:YES];
    [_stopAndPauseAnimView.layer setPosition:CGPointMake(_stopAndPauseAnimView.layer.position.x, self.view.frame.size.height+_stopAndPauseAnimView.frame.size.height/2)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionCounts;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == selectedSection)
        return 2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [FolderCell tableView:tableView folderCellWithNibName:@"FolderCell"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    NSLog(@"%i",indexPath.section);
    if (indexPath.section == 0 && inserting) {
        //config the inserting sub controls
        [FolderCell setArrowBtnHidden:YES andPlayBtnHidden:YES andRedBtnHidden:NO];
        
        //get the sound config and needed to change later after we config the sound data
        [FolderCell setClipName:folderName andColor:[UIColor redColor]];
        [FolderCell setConfigInfo:@"WAVE/PCM, 8kHz, 16Bit"];
//        inserting = FALSE;
    }
    else {
        //config the nomal sub controls
        [FolderCell setArrowBtnHidden:NO andPlayBtnHidden:NO andRedBtnHidden:YES];
        [[FolderCell playBtn] addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [FolderCell setClipName:folderName andColor:[UIColor whiteColor]];
        [FolderCell setConfigInfo:@"13-Aug-02, 146.23, 2289kb"];

    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 25.0f; //config the mask record
    else
        return 5.0f;  //every header
}

#pragma mark - Animation

- (void)recMaskAnimation
{
    [_recMaskAnimView setHidden:NO];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat positionX = -_recMaskAnimView.frame.size.width / 2 - 20.0f;
//the X position should be left alignment
        [_recMaskAnimView.layer setPosition:CGPointMake(-positionX, _recMaskAnimView.layer.position.y)];
    }completion:nil];
}

- (void)stopAndPauseAnimation
{
    [UIView animateWithDuration:0.3f delay:0.0f options: UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat positionY = self.view.frame.size.height +_stopAndPauseAnimView.frame.size.height/2;
        CGFloat y = (_stopAndPauseAnimView.layer.position.y == positionY) ? self.view.frame.size.height - _stopAndPauseAnimView.frame.size.height/2 : positionY;
        [_stopAndPauseAnimView.layer setPosition:CGPointMake(_stopAndPauseAnimView.layer.position.x, y)];
    }completion:nil];
}

- (void)cellInsertingAnimation
{
    //need to be changed later
    [_tableView beginUpdates];
    if (inserting == TRUE) {
        //config the sub controls
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        sectionCounts++;
    }
    else{
        [_tableView reloadData];
    }
    [_tableView endUpdates];
}

- (void)recAnimation
{
    [UIView animateWithDuration:0.5f delay:0.0f options: UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat positionY = self.view.frame.size.height +_recAnimView.frame.size.height/2;
        CGFloat y = (_recAnimView.layer.position.y == positionY) ? self.view.frame.size.height - _recAnimView.frame.size.height/2 : positionY;
        [_recAnimView.layer setPosition:CGPointMake(_recAnimView.layer.position.x, y)];
        
    }completion:nil];
}

#pragma mark - Button click event 

- (IBAction)stop:(id)sender {
    inserting = FALSE;
    [self recAnimation];
    [self recMaskAnimation];
    [self cellInsertingAnimation];
    [self stopAndPauseAnimation];
    //end recording, store sound data
//    [recorder stop];
    [[soundData getRecorderBySoundName:soundName] stop];
    //play
    //...
}

- (IBAction)record:(id)sender {
    inserting = TRUE;
    [self recMaskAnimation];
    [self stopAndPauseAnimation];
    [self cellInsertingAnimation];
    [_recAnimView.layer setPosition:CGPointMake(_recAnimView.layer.position.x, self.view.frame.size.height+_recAnimView.frame.size.height/2)];
    [self configAudio];
}

- (void)play:(id)sender
{
    //play sound
    //...
//    AVAudioPlayer *player;
//    [player play];
}

#pragma mark - Sound data config

- (void)configAudio
{
    //sound init
    soundName = [[[NSString alloc] initWithFormat:@"Recording File: %i", fileNumber++] copy];
    NSURL *recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:soundName]];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    //begin recording,record sound data
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:nil error:nil];
    [recorder prepareToRecord];
    [recorder record];
    [soundData storageSoundDataByFolderName:folderName andSoundName:soundName andAudioRecorder:recorder];
}

@end
