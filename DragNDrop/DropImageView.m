//
//  DropImageView.m
//  DragNDrop
//
//  Created by Dominik Hofacker on 26.11.11.
//  Copyright (c) 2011 CCoding. All rights reserved.
//

#import "DropImageView.h"

@implementation DropImageView

NSString *kPrivateDragUTI = @"com.CCoding.DragNDrop";

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
    }
    
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] && [sender draggingSourceOperationMask] & NSDragOperationCopy) {
        highlight = YES;
        
        [self setNeedsDisplay: YES];
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent forView:self classes:[NSArray arrayWithObject:[NSPasteboardItem class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            
            if (![[[draggingItem item] types] containsObject:kPrivateDragUTI]) {
                *stop = YES;
            } else {
                
                [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
            }
            
        }];
        return NSDragOperationCopy;
        }
    return NSDragOperationNone;
    
    }


- (void)draggingExited:(id<NSDraggingInfo>)sender {
    
    highlight = NO;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    if (highlight) {
        [[NSColor grayColor]set];
        [NSBezierPath setDefaultLineWidth:5];
        [NSBezierPath strokeRect:dirtyRect];
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    
    highlight = NO;
    
    [self setNeedsDisplay:YES];
    
    return  [NSImage canInitWithPasteboard:[sender draggingPasteboard]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    if ([sender draggingSource] != self) {
        NSURL *fileURL;
        
        if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]]) {
            NSImage *newImage = [[NSImage alloc] initWithPasteboard:[sender draggingPasteboard]];
            [self setImage:newImage];
        }
        
        fileURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
        [[self window] setTitle: fileURL != NULL ? [fileURL absoluteString] : @"(no name)"];
    }
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame; {
    
    NSRect ContentRect = self.window.frame;
    
    ContentRect.size = [[self image]size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask:[window styleMask]];
};

- (void)mouseDown:(NSEvent *)theEvent {
    
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, NSPasteboardTypePDF, kPrivateDragUTI, nil]];
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    NSRect draggingRect = self.bounds;
    [dragItem setDraggingFrame:draggingRect contents:[self image]];
    
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:theEvent source:self];
    
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    
    draggingSession.draggingFormation = NSDraggingFormationNone;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
        case NSDraggingContextWithinApplication:
            
        default:
            return NSDragOperationCopy;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}

- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
    
    if ([type compare:NSPasteboardTypeTIFF] == NSOrderedSame) {
        [pasteboard setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    } else if ([type compare:NSPasteboardTypePDF] == NSOrderedSame) {
        
        [pasteboard setData:[self dataWithEPSInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
}

@end
