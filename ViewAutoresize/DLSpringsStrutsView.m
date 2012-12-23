//
//  DLAnimatedView.m
//  ViewAutoresize
//
//  Created by Denis Lebedev on 12/23/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//

#import "DLSpringsStrutsView.h"

const CGFloat offset = 14.f;
const CGFloat lineCrop = 3.f;

@implementation DLSpringsStrutsView

- (void) setMask:(UIViewAutoresizing)mask {
    if (mask != _mask) {
        _mask = mask;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetShouldAntialias(context, false);
    CGContextSetRGBFillColor(context, 1.f,1.f,1.f,1.0);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
    
    CGContextSetStrokeColorWithColor(context, [NSColor darkGrayColor].CGColor);
    CGContextStrokeRect(context,CGRectInset(dirtyRect, offset, offset));
    
    CGContextSetStrokeColorWithColor(context, [NSColor redColor].CGColor);
    
    if (self.mask == UIViewAutoresizingNone) {
        [self addRightStrutInRect:dirtyRect context:context];
        [self addLeftStrutInRect:dirtyRect context:context];
        [self addTopStrutInRect:dirtyRect context:context];
        [self addBottomStrutInRect:dirtyRect context:context];
        CGContextStrokePath(context);
        return;
    }
    
    if (!(self.mask & UIViewAutoresizingFlexibleLeftMargin)) {
        [self addLeftStrutInRect:dirtyRect context:context];
    }
    
    if (!(self.mask & UIViewAutoresizingFlexibleRightMargin)) {
        [self addRightStrutInRect:dirtyRect context:context];
    }
    
    if (!(self.mask & UIViewAutoresizingFlexibleBottomMargin)) {
        [self addBottomStrutInRect:dirtyRect context:context];
    }

    if (!(self.mask & UIViewAutoresizingFlexibleTopMargin)) {
        [self addTopStrutInRect:dirtyRect context:context];
    }
    
    if (self.mask & UIViewAutoresizingFlexibleWidth) {
        CGContextMoveToPoint (context, offset + lineCrop, dirtyRect.size.height /2);
        CGContextAddLineToPoint(context, dirtyRect.size.width - offset - lineCrop, dirtyRect.size.height /2);
    }
    
    if (self.mask & UIViewAutoresizingFlexibleHeight) {
        CGContextMoveToPoint (context, dirtyRect.size.width / 2, offset + lineCrop);
        CGContextAddLineToPoint(context, dirtyRect.size.width / 2, dirtyRect.size.height - offset - lineCrop);
    }
    
    CGContextStrokePath(context);
}


- (void)addLeftStrutInRect:(NSRect)rect context:(CGContextRef)context {
    CGContextMoveToPoint (context, lineCrop, rect.size.height /2);
    CGContextAddLineToPoint (context, offset - lineCrop, rect.size.height /2);
}

- (void)addRightStrutInRect:(NSRect)rect context:(CGContextRef)context {
    CGContextMoveToPoint (context, rect.size.width - lineCrop, rect.size.height /2);
    CGContextAddLineToPoint (context, rect.size.width - offset + lineCrop, rect.size.height /2);
}

- (void)addBottomStrutInRect:(NSRect)rect context:(CGContextRef)context {
    CGContextMoveToPoint(context, rect.size.width /2, lineCrop);
    CGContextAddLineToPoint(context, rect.size.width /2, offset - lineCrop);
}

- (void)addTopStrutInRect:(NSRect)rect context:(CGContextRef)context {
    CGContextMoveToPoint(context, rect.size.width / 2, rect.size.height - lineCrop);
    CGContextAddLineToPoint(context, rect.size.width / 2, rect.size.height - offset + lineCrop);
}

@end
