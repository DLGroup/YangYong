//
//  RecordingViewController.m
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "RecordingViewController.h"

static NSString *className;

@implementation RecordingViewController

+ (void)setClassName:(NSString *)name
{
    className = [[NSString alloc] initWithFormat:@"%@", name];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = className;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
