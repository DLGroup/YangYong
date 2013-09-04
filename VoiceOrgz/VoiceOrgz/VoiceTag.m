//
//  VoiceTag.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "VoiceTag.h"
#import "VoiceMainView.h"
#import "VoiceInfo.h"
#import "SharedObj.h"
#import "TagNew.h"
@interface VoiceTag ()

@end

@implementation VoiceTag

@synthesize imageView=_imageView;
@synthesize tableView=_tableView;
@synthesize tagName=_tagName;

- (void)dealloc{
    NSLog(@"voicetag dealloc");
    _tableView=nil;
    _imageView=nil;
    _tagName=nil;
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"Tags";
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

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[SharedObj sharedObj].tag count]+1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    VoiceInfo *voice=mainView.voice;
    NSString *cellId=@"BaseCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"TagListCell" owner:self options:nil] lastObject];
    }
    UILabel *tagName=(UILabel*)[cell viewWithTag:101];
    UIView *acessView=[cell viewWithTag:103];
    UIView *imageView=[cell viewWithTag:102];
    //Add folder
    if(indexPath.row==0){
        tagName.text=@"New Tag";
        acessView.hidden=NO;
        imageView.hidden=YES;
        tagName.font=[UIFont italicSystemFontOfSize:14.0f];
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else{
        acessView.hidden=YES;
        imageView.hidden=NO;
        tagName.font=[UIFont systemFontOfSize:14.0f];
        cell.selectionStyle=UITableViewCellEditingStyleNone;
    }

    
    NSArray *keys=[[SharedObj sharedObj].tag allKeys];
    
    tagName.text=[keys objectAtIndex:indexPath.row-1];
    
    if([voice.tag containsObject:tagName.text])
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
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
        TagNew *tagNew=[[TagNew alloc] initWithNibName:@"TagNew" bundle:nil lastTagName:nil];
        [self.navigationController pushViewController:tagNew animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UILabel *tagName=(UILabel*)[cell viewWithTag:101];

    UINavigationController *nav=(UINavigationController*)self.presentingViewController;
    VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
    VoiceInfo *voice=mainView.voice;
    
    NSMutableArray *array=[[SharedObj sharedObj].tag objectForKey:tagName.text];
    int i=0;
    for(; i<[SharedObj sharedObj].voice.count; ++i){
        if([[SharedObj sharedObj].voice objectAtIndex:i] == voice)
            break;
    }
    int voiceIdx=i;
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [voice.tag addObject:tagName.text];
        [array addObject:[NSNumber numberWithInt:voiceIdx]];
    }
    else{
        cell.accessoryType=UITableViewCellAccessoryNone;
        [voice.tag removeObject:tagName.text];
        [array removeObject:[NSNumber numberWithInt:voiceIdx]];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    if(_tagName){
        UINavigationController *nav=(UINavigationController*)self.presentingViewController;
        VoiceMainView *mainView=(VoiceMainView*)nav.topViewController;
        VoiceInfo *voice=mainView.voice;
        
        NSMutableArray *array=[[SharedObj sharedObj].tag objectForKey:_tagName];
        int i=0;
        for(; i<[SharedObj sharedObj].voice.count; ++i){
            if([[SharedObj sharedObj].voice objectAtIndex:i] == voice)
                break;
        }
        int voiceIdx=i;
        
        [voice.tag addObject:_tagName];
        [array addObject:[NSNumber numberWithInt:voiceIdx]];
        [_tableView reloadData];
    }
}
@end




