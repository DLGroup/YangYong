//
//  MyView.m
//  CADemo
//
//  Created by tll007 on 12/27/12.
//  Copyright (c) 2012 diluntech. All rights reserved.
//

#import "MyView.h"

@implementation MyView

@synthesize delegate=_delegate;
- (void)mouseDown:(NSEvent*)theEvent {
    [_delegate mouseDown:theEvent];
}
@end
