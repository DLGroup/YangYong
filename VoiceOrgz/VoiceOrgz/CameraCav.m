//
//  CameraCav.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 3/14/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "CameraCav.h"

#define LINE_SPACE 130;


@implementation CameraCav

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    int offset=LINE_SPACE;
    
    while(offset < self.frame.size.height){
        CGContextMoveToPoint(context, 0.0f, offset);
        CGContextAddLineToPoint(context, self.frame.size.width, offset);
        
        offset += LINE_SPACE;
    }
    
    offset =LINE_SPACE;
    while(offset < self.frame.size.width){
        CGContextMoveToPoint(context, offset, 0.0f);
        CGContextAddLineToPoint(context, offset, self.frame.size.height);
        
        offset += LINE_SPACE;
    }
    [[UIColor lightGrayColor] setStroke];
    CGContextStrokePath(context);
    
}


@end
