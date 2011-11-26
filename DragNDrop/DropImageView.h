//
//  DropImageView.h
//  DragNDrop
//
//  Created by Dominik Hofacker on 26.11.11.
//  Copyright (c) 2011 CCoding. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface DropImageView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider> {
    
    BOOL highlight;
}

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
