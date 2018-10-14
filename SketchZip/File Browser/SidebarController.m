//
//  SidebarController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 24/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SidebarController.h"
#import <PureLayout/PureLayout.h>


@implementation NSView (TDView)

//+ (instancetype)view {
//    NSView *view = [self new];
//    
////    view.wantsLayer = YES;
//    view.translatesAutoresizingMaskIntoConstraints = NO;
//    view.backgroundColor = [NSColor colorWithDeviceRed:0.945 green:0.945 blue:0.953 alpha:1.000];
//    
//    return view;
//}

- (NSColor *)backgroundColor {
    if(!self.layer.backgroundColor) {
        return nil;
    }
    
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    self.wantsLayer = YES;
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.wantsLayer = YES;
    self.layer.cornerRadius = cornerRadius;
}

@end


@implementation SidebarHeaderView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:NSMakeRect(0, 0, 120, 44)];
    
    NSView *highlightView = [[NSView alloc] init];
    highlightView.cornerRadius = 4;
    highlightView.wantsLayer = YES;
//    highlightView.layer.backgroundColor = [[NSColor redColor] CGColor];
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
    
    NSButton *disclosureButton = [NSButton buttonWithTitle:@"BLA" target:nil action:nil];
    disclosureButton.hidden = YES;
    [self.highlightView addSubview:disclosureButton];
    self.disclosureButton = disclosureButton;
    
    
    // Auto layout
    [self.highlightView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 16, 0, 16)];
//    [self.highlightView autoSetDimension:ALDimensionWidth toSize:28];
//    [self.highlightView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.iconView autoSetDimensionsToSize:CGSizeMake(20, 20)];
//    [self.iconView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.iconView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    
//    [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.highlightView withOffset:0];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iconView withOffset:4];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4];
    
//    [self.disclosureButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.disclosureButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
    [self.disclosureButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4];
    
    return self;
}

@end


@implementation SidebarCollectionViewItem

- (void)loadView {
    self.view = [[NSView alloc] init];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSView *highlightView = [[NSView alloc] init];
    highlightView.cornerRadius = 4;
    [self.view addSubview:highlightView];
    self.highlightView = highlightView;
    
    NSImageView *iconView = [[NSImageView alloc] init];
    [self.highlightView addSubview:iconView];
    self.iconView = iconView;
    
    NSTextField *titleLabel = [NSTextField labelWithString:@"Title"];
    titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
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
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.highlightView.backgroundColor = [NSColor headerBackgroundColor];
    }
    else {
        self.highlightView.backgroundColor = [NSColor clearColor];
    }
}

@end


@interface SidebarController () <TDCollectionViewListLayoutDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (strong) NSArray          *items;
@property (strong) NSMutableArray   *sketchFiles;

@property (assign) BOOL             fileSectionCollapsed;

@end


@implementation SidebarController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];

    self.items = @[@"Everything", @"Recents", @"Favorites"];
    self.sketchFiles = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 240, 640)];
    self.view.backgroundColor = [NSColor backgroundColor];
        
    self.sidebarLayout = [[SidebarLayout alloc] init];

    self.collectionView = [[NSCollectionView alloc] initWithFrame:self.scrollView.bounds];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = self.sidebarLayout;
    self.collectionView.selectable = YES;
    self.collectionView.allowsEmptySelection = NO;
    [self.collectionView registerClass:[SidebarCollectionViewItem class] forItemWithIdentifier:@"SidebarItem"];
    [self.collectionView registerClass:[SidebarHeaderView class] forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SidebarHeaderIdentifier"];
    self.collectionView.backgroundColors = @[[NSColor backgroundColor]];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 640, 640)];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.automaticallyAdjustsContentInsets = NO;
//    self.scrollView.autohidesScrollers = YES;
//    self.scrollView.hasHorizontalScroller = NO;
//    self.scrollView.hasVerticalScroller = NO;
//    self.scrollView.horizontalScroller = nil;
//    self.scrollView.verticalScroller = nil;
    self.scrollView.scrollerStyle = NSScrollerStyleOverlay;
    self.scrollView.contentInsets = NSEdgeInsetsMake(48, 0, 0, 0);
    self.scrollView.backgroundColor = [NSColor backgroundColor];
    self.scrollView.documentView = self.collectionView;
    [self.view addSubview:self.scrollView];
    
    NSView *divider = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1, 120)];
    divider.wantsLayer = YES;
    divider.layer.backgroundColor = [[NSColor dividerColor] CGColor];
    [self.view addSubview:divider];

    // Autolayout
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0)];
    
    [divider autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [divider autoSetDimension:ALDimensionWidth toSize:1];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.scrollView.verticalScroller.alphaValue = 0.0;
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    if([self.sidebarLayout collapsedSectionAtIndex:section]) {
//        return 0;
//    }

    if(section == 1) {
        return self.sketchFiles.count;
    }
    
    return self.items.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        return [self collectionView:collectionView fileItemForRepresentedObjectAtIndexPath:indexPath];
    }
    
    SidebarCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"SidebarItem" forIndexPath:indexPath];
    
    if(indexPath.item == 0) {
        item.titleLabel.stringValue = @"All";
        item.iconView.image = [NSImage imageNamed:@"Everything"];
    }
    if(indexPath.item == 1) {
        item.titleLabel.stringValue = @"Recents";
        item.iconView.image = [NSImage imageNamed:@"Recents"];
    }
    if(indexPath.item == 2) {
        item.titleLabel.stringValue = @"Favorites";
        item.iconView.image = [NSImage imageNamed:@"Favorites"];
    }
    return item;
}

- (void)addSketchFile:(SketchFile *)sketchFile {
    [self.sketchFiles addObject:sketchFile];
    [self.collectionView reloadData];
}

- (SketchFile *)sketchFileAtIndex:(NSInteger)index {
    return [self.sketchFiles objectAtIndex:index];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView fileItemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    SidebarCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"SidebarItem" forIndexPath:indexPath];
    SketchFile *file = [self sketchFileAtIndex:indexPath.item];
    
    item.titleLabel.stringValue = [file.name stringByDeletingPathExtension] ;
    item.iconView.image = [NSImage imageNamed:@"File"];

    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        if([self.delegate respondsToSelector:@selector(sidebarController:didSelectItem:atIndexPath:)]) {
            [self.delegate sidebarController:self didSelectItem:nil atIndexPath:indexPath];
        }
        
        if(indexPath.section == 0 && indexPath.item == 1) {
        }
    }
}

- (void)toggleSection:(NSButton *)button {
    [self.sidebarLayout toggleSectionAtIndex:button.tag];
    [self.collectionView.animator reloadSections:[NSIndexSet indexSetWithIndex:button.tag]];
}

- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath {
    SidebarHeaderView *headerView = [collectionView makeSupplementaryViewOfKind:NSCollectionElementKindSectionHeader withIdentifier:@"SidebarHeaderIdentifier" forIndexPath:indexPath];
//    AssetGroup *group = [self.assetCollection groupAtIndex:indexPath.section];
    
    NSString *title = @"Collections";
    
    if(indexPath.section == 1) {
        title = @"Files";
    }

    headerView.titleLabel.stringValue = title;
    headerView.disclosureButton.tag = indexPath.section;
    headerView.disclosureButton.target = self;
    headerView.disclosureButton.action = @selector(toggleSection:);
    
    return headerView;
}

@end
