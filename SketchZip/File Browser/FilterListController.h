//
//  FilterListController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 07/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Purelayout/Purelayout.h>

#import "Filter.h"
#import "TDTheme.h"


@interface FilterItemView : NSTableCellView

@property (strong) NSImageView  *iconView;
@property (strong) NSTextField  *titleLabel;
@property (strong) NSView       *highlightView;

@end


@interface FilterGroup : NSObject

@property (strong) NSString     *name;
@property (strong) NSArray      *filters;
@property (assign) BOOL         expanded;

@end


@interface FilterListController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong) NSScrollView     *scrollView;
@property (strong) NSOutlineView    *outlineView;
@property (strong) NSArray          *filterGroups;

@end
