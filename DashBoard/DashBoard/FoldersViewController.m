//
//  FoldersViewController.m
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "FoldersViewController.h"
#include "DetailRecordController.h"
#import "FolderCell.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "Persistence.h"
#import "RecordInfo.h"

#define CELLHEIGHT 67.0f

@interface FoldersViewController ()
{
    NSString *folderName;
    NSUInteger selectedSection; //show slider cell or not
    BOOL inserting;               //insert cell animationly
    NSMutableString *recordName;//the name of every sound file
    Persistence *persistence;
    RecordInfo *recordInfo;
    
// recorder and player and session
    AVAudioSession *session;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
//object is CellInfo Class,which will be config every cell initially
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//control the property enabled
@property (weak, nonatomic) IBOutlet UIButton *recBtn;

//animation property
@property (strong, nonatomic) IBOutlet UIView *recAnimView;
@property (strong, nonatomic) IBOutlet UIView *stopAndPauseAnimView;
@property (strong, nonatomic) IBOutlet UIView *recMaskAnimView;

- (IBAction)stop:(id)sender;
- (IBAction)record:(id)sender;

@end

@implementation FoldersViewController

@synthesize tableView = _tableView;
@synthesize recBtn = _recBtn;
@synthesize recAnimView = _recAnimView;
@synthesize stopAndPauseAnimView = _stopAndPauseAnimView;
@synthesize recMaskAnimView = _recMaskAnimView;

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)name
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        folderName = name;
        self.title = folderName;
        sectionCounts = 0;
        selectedSection = -1;
        inserting = TRUE;
        recordName = [[NSMutableString alloc] initWithFormat:@"%@,file:0", folderName];
        allRecordsConfigInfo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // realize the right bar button and initial
    UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:folderName style:UIBarButtonItemStyleBordered target:nil action:nil];
    back.tintColor=[UIColor blackColor];
    self.navigationItem.backBarButtonItem=back;
    
    //config the sound session
    session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    //...singleton mode
    persistence = [Persistence sharedPersistence];
    recordInfo = nil;

}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"view will disappear call");
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear call");
    [self recAnimation];
    [self reloadRecords];
//    NSLog(@"allRecordsconfiginfo %@",[allRecordsConfigInfo objectAtIndex:0]);

    [_tableView reloadData];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [_recAnimView.layer setPosition:CGPointMake(_recAnimView.layer.position.x, self.view.frame.size.height+_recAnimView.frame.size.height/2)];
    [_recMaskAnimView.layer setPosition:CGPointMake(-_recMaskAnimView.frame.size.width/2, _recMaskAnimView.layer.position.y)];
    [_recMaskAnimView setHidden:YES];
    [_stopAndPauseAnimView.layer setPosition:CGPointMake(_stopAndPauseAnimView.layer.position.x, self.view.frame.size.height+_stopAndPauseAnimView.frame.size.height/2)];
    recordInfo = nil;
//    persistence = nil;
//    session = nil;
//    player = nil;
//    recorder = nil;
    allRecordsConfigInfo  = nil;
    allRecordsConfigInfo = [[NSMutableArray alloc] init];
    sectionCounts = 0;
//    recordName = nil;
}

#pragma mark - Reload method according persistence data

- (void) reloadRecords
{
    //persistence里面有两个NSMutableDictionary，此处使用的是次级dictionary
    NSMutableDictionary *records = [persistence getRecordsByFolderName:folderName];
    for (NSString *name in [records allKeys]) {
        RecordInfo *therecordInfo = [persistence getRecordByFolderName:folderName andRecordName:name];
        [allRecordsConfigInfo addObject:therecordInfo];
        sectionCounts++;
    }
    
    NSLog(@"voice count:%d", sectionCounts);
    inserting = FALSE;
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
// --------------------------------------
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UITableViewCell *cell = [FolderCell tableView:tableView folderCellWithNibName:@"FolderCell"];
    
    if (indexPath.section==0 && inserting)
    {
        [FolderCell setArrowBtnHidden:YES andPlayBtnHidden:YES andRedBtnHidden:NO];
        [FolderCell setClipName:[self recorderTimer] andColor:[UIColor redColor]];
        [FolderCell setConfigInfo:[self recorderConfigInfo]];
    }
    else
    {
        recordInfo = [allRecordsConfigInfo objectAtIndex:indexPath.section];
        //config the nomal sub controls
        [FolderCell setArrowBtnHidden:NO andPlayBtnHidden:NO andRedBtnHidden:YES];
        [[FolderCell playBtn] addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [[FolderCell arrowBtn] addTarget:self action:@selector(arrow:) forControlEvents:UIControlEventTouchUpInside];
        //...
        [FolderCell setClipName:[recordInfo recordName] andColor:[UIColor whiteColor]];
        [FolderCell setConfigInfo:[self recorderFileInfo]];
    }
    
    if (indexPath.row==0)
        return cell;
    else
    {
        static NSString *str1 = @"SliderCell";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:str1];
        if (cell1==nil) {
            cell1 = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SliderCell" owner:self options:nil] lastObject];
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell1;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return CELLHEIGHT;
    else
        return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (inserting && section == 0)
        return 25.0f; //config the mask record
    else
        return 5.0f;  //every header
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    return headerView;
}

#pragma mark - Animation

- (void)recMaskAnimation
{
    [_recMaskAnimView setHidden:NO];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat positionX = _recMaskAnimView.frame.size.width / 2 + 20.0f;
        CGFloat x = (_recMaskAnimView.layer.position.x == positionX) ? -positionX:positionX;
        [_recMaskAnimView.layer setPosition:CGPointMake(x, _recMaskAnimView.layer.position.y)];
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
// ---------------------
    //...every time we click the stop button we should save the
    //...information of the newly recorder
    //把新建的cell加到allCellsConfigInfo里面，并更新后台数据
    //recordInfo至少要保存指向recorder的文件路径信息、、、、
//    RecordInfo *newrecordInfo = [recordInfo copy];
    [allRecordsConfigInfo addObject:recordInfo];
    //...同步到后台...toFolder有没必要
    [persistence addRecord:recordInfo toFolder:folderName];
    [recorder stop];
    recorder = nil;
// ---------------------
    inserting = FALSE;
    [self recAnimation];
    [self recMaskAnimation];
    [self cellInsertingAnimation];
    [self stopAndPauseAnimation];
    
}

- (IBAction)record:(id)sender {
    inserting = TRUE;
    [self configAudio];
    [self recMaskAnimation];
    [self stopAndPauseAnimation];
    [self cellInsertingAnimation];
    [_recAnimView.layer setPosition:CGPointMake(_recAnimView.layer.position.x, self.view.frame.size.height+_recAnimView.frame.size.height/2)];
}

- (void)arrow:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    UILabel *recordLabel = (UILabel *)[cell viewWithTag:103];
    DetailRecordController *detailRecord = [[DetailRecordController alloc] initWithNibName:@"DetailRecordController" bundle:nil folderName:folderName andRecordName:recordLabel.text];
    [self.navigationController pushViewController:detailRecord animated:YES];
}

- (void)play:(id)sender
{    
    [_tableView beginUpdates];
    
    UIButton *btn=(UIButton*)sender;
    NSIndexPath *_path=nil;
    UITableViewCell *cell=(UITableViewCell*)[[btn superview] superview];
    
    int _lastSelectedIdx=selectedSection;
    if (selectedSection != -1) {
        _path=[NSIndexPath indexPathForRow:1 inSection:selectedSection];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_path] withRowAnimation:UITableViewRowAnimationAutomatic];
        recordName = [[NSMutableString alloc] initWithFormat:@"%@,record:%i", folderName, selectedSection];
        selectedSection = -1;
        _recBtn.enabled = YES;
    }
    
    _path=[_tableView indexPathForCell:cell];
    
    if (_path.section != _lastSelectedIdx) {
        NSIndexPath *path=[NSIndexPath indexPathForRow:1 inSection:_path.section];
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationAutomatic];
        selectedSection=_path.section;
        ;
        _recBtn.enabled = NO;
        NSError *playerError;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[self dataFilePathURL:recordName] error:&playerError];
        if (player == nil) {
            NSLog(@"Error creating player: %@", [playerError description]);
        }
    }
    [_tableView endUpdates];
    
    recordName = [[NSMutableString alloc] initWithFormat:@"%@,file:%i", folderName, selectedSection];
    NSString *playerName = [[NSMutableString alloc] initWithFormat:@"%@,record:%i", folderName, selectedSection];
    NSLog(@"playerName: %@", playerName);

// ---------------------------
    //set the player information
    
    
    //    player.delegate =self;
    if (player ==nil) {
        NSLog(@"player is nill. somewhere error happened!");
    }
    if ([player isPlaying]) {
        [player pause];
        [btn setBackgroundImage:[UIImage imageNamed:@"blueplayer"] forState:UIControlStateNormal];
    }
    else {
        [player play];
        [btn setBackgroundImage:[UIImage imageNamed:@"playlist_roundicon"] forState:UIControlStateNormal];
    }
// ---------------------------
}

#pragma mark - Sound data config

- (void)configAudio
{
    recordName = [[NSMutableString alloc] initWithFormat:@"%@,file:%i", folderName, sectionCounts];
    recordInfo = [[RecordInfo alloc] initWithRecordName:recordName andFolderName:folderName];
// ---------------------------
    NSString *recorderName = [[NSMutableString alloc] initWithFormat:@"%@,record:%i", folderName, sectionCounts];
    recorder = [[AVAudioRecorder alloc] initWithURL:[self dataFilePathURL:recorderName] settings:nil error:nil];
    [recorder prepareToRecord];
    [recorder record];

//    player = nil;
}

- (NSURL *)dataFilePathURL:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - Config information of record

- (NSString*/*NSTimer*/)recorderTimer
{
    return @"timer";
}

- (NSString *)recorderConfigInfo
{
    return @"recorder config information";
}

- (NSString *)recorderFileInfo
{
    return @"recorder file information";
}

@end
