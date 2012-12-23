//
//  DLMaskView.m
//  ViewAutoresize
//
//  Created by Denis Lebedev on 12/23/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//

#import "DLMaskView.h"

@implementation DLMaskView

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetStrokeColorWithColor(context, [NSColor greenColor].CGColor);
    CGContextStrokeRect(context, NSRectToCGRect(dirtyRect));
}


@end
