//
//  DLViewMask.m
//  ViewAutoresize
//
//  Created by Denis Lebedev on 12/23/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//

#import "DLMaskHelper.h"
#import "DLMaskView.h"
#import "DLSpringsStrutsView.h"

static CGFloat const kViewSize = 50.f;
static NSString *const kDLShowSizingsPreferencesKey = @"kDLShowSizingsPreferencesKey";

@interface DLMaskHelper ()

@end

@implementation DLMaskHelper

+ (void) pluginDidLoad:(NSBundle *)plugin {
	static id sharedPlugin = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
	}
	return self;
}

- (void) applicationDidFinishLaunching: (NSNotification*) notification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    
    
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show autoresizing masks"
                                                             action:@selector(toggleMasks:)
                                                      keyEquivalent:@"m"];
        [newMenuItem setTarget:self];
        [newMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:newMenuItem];
        [newMenuItem release];
    }
}

- (void)selectionDidChange:(NSNotification*)notification {
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[notification object];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kDLShowSizingsPreferencesKey]) {
            return;
        }
        
        NSArray* selectedRanges = [textView selectedRanges];
		if (selectedRanges.count >= 1) {
			NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
			NSString *text = textView.textStorage.string;
			NSRange lineRange = [text lineRangeForRange:selectedRange];
			NSString *line = [text substringWithRange:lineRange];

            NSRange colorRange = [line rangeOfString:@"autoresizingMask"];
            if (colorRange.location != NSNotFound) {
                NSRange selectedColorRange = NSMakeRange(colorRange.location + lineRange.location, colorRange.length);
                NSRect selectionRectOnScreen = [textView firstRectForCharacterRange:selectedColorRange];
				NSRect selectionRectInWindow = [textView.window convertRectFromScreen:selectionRectOnScreen];
                NSRect selectionRectInView = [textView convertRect:selectionRectInWindow fromView:nil];
                
                self.maskView.frame = NSInsetRect(NSIntegralRect(selectionRectInView), -1, -1);
                self.sizingView.frame = NSMakeRect(CGRectGetMaxX(selectionRectInView) - kViewSize + 1,
                                                   CGRectGetMinY(selectionRectInView) - kViewSize - 1,
                                                   kViewSize,
                                                   kViewSize);
                [textView addSubview:self.maskView];
                [textView addSubview:self.sizingView];

                /*enum {
                    NSViewNotSizable     = 0,
                    NSViewMinXMargin     = 1,
                    NSViewWidthSizable   = 2,
                    NSViewMaxXMargin     = 4,
                    NSViewMinYMargin     = 8,
                    NSViewHeightSizable  = 16,
                    NSViewMaxYMargin     = 32
                };*/
                
                NSArray *masks = @[@"UIViewAutoresizingFlexibleLeftMargin",
                @"UIViewAutoresizingFlexibleWidth",
                @"UIViewAutoresizingFlexibleRightMargin",
                @"UIViewAutoresizingFlexibleTopMargin",
                @"UIViewAutoresizingFlexibleHeight",
                @"UIViewAutoresizingFlexibleBottomMargin"];
                
                UIViewAutoresizing sizing = UIViewAutoresizingNone;
                for (int i = 0; i < [masks count]; i++) {
                    if ([line rangeOfString:masks[i]].location != NSNotFound) {
                        sizing = sizing | (1 << i);
//                        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
//                        [alert setMessageText:masks[i]];
//                        [alert runModal];
                    }
                }
                self.sizingView.mask = sizing;
             }
            else {
                [self dismissViews];
            }
        } else {
            [self dismissViews];
        }
    }
}

- (void)dismissViews {
    [self.maskView removeFromSuperview];
    [self.sizingView removeFromSuperview];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(insertColor:)) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
	} else if ([menuItem action] == @selector(toggleMasks:)) {
		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDLShowSizingsPreferencesKey];
		[menuItem setState:enabled ? NSOnState : NSOffState];
		return YES;
    }
	return YES;
}

- (void)toggleMasks:(id)sender {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDLShowSizingsPreferencesKey];
    if (enabled) {
        [self dismissViews];
    }
	[[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:kDLShowSizingsPreferencesKey];
}

#pragma mark - Getters

- (DLMaskView *)maskView {
    if (!_maskView) {
        self.maskView = [[DLMaskView alloc] initWithFrame:NSZeroRect];
    }
    return _maskView;
}

- (DLSpringsStrutsView *)sizingView {
    if (!_sizingView) {
        self.sizingView = [[DLSpringsStrutsView alloc] initWithFrame:NSZeroRect];
    }
    return _sizingView;
}

- (void)dealloc
{   [_sizingView release];
    [_maskView release];
    [super dealloc];
}
@end
