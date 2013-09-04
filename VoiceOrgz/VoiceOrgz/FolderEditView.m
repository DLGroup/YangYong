//
//  FolderEditView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/2/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "FolderEditView.h"
#import "SharedObj.h"
#import "DirInfo.h"
#import "FolderNew.h"
#import "VoiceInfo.h"
@interface FolderEditView ()

@end

@implementation FolderEditView

- (void)dealloc{
    NSLog(@"foldereditview dealloc");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        rightBarBtnItem.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem=rightBarBtnItem;
        
        UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
        leftBarBtnItem.tintColor=[UIColor blackColor];
        self.navigationItem.leftBarButtonItem=leftBarBtnItem;

    }
    return self;
}

- (void)add{
    FolderNew *folderNewView=[[FolderNew alloc] initWithNibName:@"FolderNew" bundle:nil lastFolderName:nil];
    [self.navigationController pushViewController:folderNewView animated:YES];

}

- (void)done{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView* customView = [[UIView alloc]
                          initWithFrame:CGRectMake(0.0, 0.0, 300.0, 35.0)];
	
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font=[UIFont italicSystemFontOfSize:17.0f];
	headerLabel.frame = CGRectMake(40.0, 0.0, 300.0, 35.0);
    headerLabel.text = @"My Folders";
	[customView addSubview:headerLabel];
    
    return customView;
}


// Delete folder
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *folderName=[[SharedObj sharedObj].dirInfo.subDirs objectAtIndex:indexPath.row+1];
    DirInfo *dirInfo=[[SharedObj sharedObj].dirInfo.dirsMap objectForKey:folderName];
    
    //Delete all voice file and pictures
     NSFileManager *fm = [NSFileManager defaultManager];
    int idx=0;
    for(; idx<dirInfo.voices.count; ++idx){
        int voiceIdx=[[dirInfo.voices objectAtIndex:idx] intValue];
        VoiceInfo *_voice=[[SharedObj sharedObj].voice objectAtIndex:voiceIdx];
        
        //Delete all pictures
        for(int i=0; i<_voice.imgArray.count; ++i){
            [fm removeItemAtPath:[_voice.imgArray objectAtIndex:i] error:nil];
        }
        
     
        //Refresh other dir's voice index
        for(NSString *dirName in [SharedObj sharedObj].dirInfo.dirsMap){
            DirInfo *_dirInfo=[[SharedObj sharedObj].dirInfo.dirsMap objectForKey:dirName];
            int _voiceIdx=0;
            for(int i=0; i<_dirInfo.voices.count; ++i){
                _voiceIdx=[[_dirInfo.voices objectAtIndex:i] intValue];
                if(_voiceIdx > voiceIdx)
                    [_dirInfo.voices replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:_voiceIdx-1]];
            }
            
        }
        
        //Refresh voice index in tag map
        for(NSString *tagName in [SharedObj sharedObj].tag){
            NSMutableArray *array=[[SharedObj sharedObj].tag objectForKey:tagName];
            int delIdx=-1;
            int _voiceIdx=0;
            for(int i=0; i<array.count; ++i){
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
        [[SharedObj sharedObj].voice removeObjectAtIndex:voiceIdx];

    }
    
    [dirInfo.voices removeAllObjects];
    [[SharedObj sharedObj].dirInfo.dirsMap removeObjectForKey:folderName];
    [[SharedObj sharedObj].dirInfo.subDirs removeObject:folderName];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
               withRowAnimation:UITableViewRowAnimationFade];
}

// Reorder folder
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    UITableViewCell *srcCell=[tableView cellForRowAtIndexPath:sourceIndexPath];
    UITableViewCell *destCell=[tableView cellForRowAtIndexPath:destinationIndexPath];
    
    NSString *srcFolder=((UILabel*)[srcCell viewWithTag:101]).text;
    NSString *destFolder=((UILabel*)[destCell viewWithTag:101]).text;

    NSMutableArray *array = [SharedObj sharedObj].dirInfo.subDirs;
    int srcIdx=[array indexOfObject:srcFolder];
    int destIdx=[array indexOfObject:destFolder];
    
    [array exchangeObjectAtIndex:srcIdx withObjectAtIndex:destIdx];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView setEditing:YES animated:YES];
    self.title=@"Folders";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[SharedObj sharedObj].dirInfo.subDirs count]-1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellId=@"BaseCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderEditCell" owner:self options:nil] lastObject];
    }
    
    UILabel *folderNameLabel=(UILabel*)[cell viewWithTag:101];
    folderNameLabel.text=[[SharedObj sharedObj].dirInfo.subDirs objectAtIndex:indexPath.row+1];
    cell.showsReorderControl=YES;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor=[UIColor lightGrayColor];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *folderName=[[SharedObj sharedObj].dirInfo.subDirs objectAtIndex:indexPath.row+1];
    FolderNew *folderNewView=[[FolderNew alloc] initWithNibName:@"FolderNew" bundle:nil lastFolderName:folderName];
    [self.navigationController pushViewController:folderNewView animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [_tableView reloadData];
}
@end






