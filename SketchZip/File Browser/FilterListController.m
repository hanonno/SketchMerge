//
//  FilterListController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 07/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "FilterListController.h"


@implementation FilterItemView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:NSMakeRect(0, 0, 120, 44)];
    
    NSView *highlightView = [[NSView alloc] init];
//    highlightView.cornerRadius = 4;
    [self addSubview:highlightView];
    self.highlightView = highlightView;
    
    NSImageView *iconView = [[NSImageView alloc] init];
    [self.highlightView addSubview:iconView];
    self.iconView = iconView;
    
    NSTextField *titleLabel = [NSTextField labelWithString:@"Title"];
    titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    titleLabel.textColor = [NSColor titleTextColor];
    [self.highlightView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // Auto layout
    [self.highlightView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 16, 0, 16)];
    
    [self.iconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [self.iconView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.iconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    
    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.highlightView withOffset:0];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iconView withOffset:5];
    
    return self;
}

@end


@implementation FilterGroup

@end


@interface FilterListController ()

@end


@implementation FilterListController

- (instancetype)init {
    self = [super init];
    
    FilterGroup *sizeFilters = [[FilterGroup alloc] init];
    sizeFilters.name = @"Sizes";
    sizeFilters.filters = [SizeFilter appleDeviceFilters];
    sizeFilters.expanded = YES;
    
    _filterGroups = @[sizeFilters];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] init];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 120, 480)];
    [self.view addSubview:self.scrollView];
    
    self.outlineView = [[NSOutlineView alloc] init];
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    
    [self.outlineView sizeLastColumnToFit];
    [self.outlineView reloadData];
    [self.outlineView setFloatsGroupRows:NO];
    [self.outlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"FilterItemView" bundle:[NSBundle mainBundle]];
    
    [self.outlineView registerNib:nib forIdentifier:@"FilterItemView"];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [self.outlineView expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];

    self.scrollView.documentView = self.outlineView;
    
    // Autolayout
    [self.scrollView autoPinEdgesToSuperviewEdges];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if(item == nil) {
        return self.filterGroups.count;
    }
    
    FilterGroup *filterGroup = (FilterGroup *)item;
    return filterGroup.filters.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if(item == nil) {
        return [self.filterGroups objectAtIndex:index];
    }
    
    FilterGroup *filterGroup = (FilterGroup *)item;
    return [filterGroup.filters objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    if([item isKindOfClass:[FilterGroup class]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if([item isKindOfClass:[FilterGroup class]]) {
        return YES;
    }
    
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if([item isKindOfClass:[FilterGroup class]]) {
        NSTextField *label = [NSTextField labelWithString:@"Bla"];
        return label;
    }
    
    FilterItemView *filterItemView = [[FilterItemView alloc] initWithFrame:NSMakeRect(0, 0, 120, 44)];
    
    NSLog(@"Return filter item view");
    
    return filterItemView;
}


@end
