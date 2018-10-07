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

    self.filterTokenField = [[NSTokenField alloc] initWithFrame:NSMakeRect(0, 0, 240, 52)];
    self.previewSizeSlider = [[NSSlider alloc] init];
    self.sizeFilterPicker = [[SizeFilterPicker alloc] init];
    
    self.fileSectionCollapsed = NO;
    
    return self;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 240, 640)];
    self.view.backgroundColor = [NSColor backgroundColor];
    
    self.filterTokenField.tokenStyle = NSTokenStyleSquared;
    //    self.tokenField.tokenStyle = NSTokenStylePlainSquared;
    self.filterTokenField.bezelStyle = NSTextFieldRoundedBezel;
    self.filterTokenField.delegate = self;
    [self.view addSubview:self.filterTokenField];
    
    self.previewSizeSlider.minValue = 240;
    self.previewSizeSlider.maxValue = 2048;
    self.previewSizeSlider.altIncrementValue = 120;
    [self.view addSubview:self.previewSizeSlider];
    
    self.listLayout = [[TDCollectionViewListLayout alloc] init];
    self.listLayout.rowHeight = 28;
    self.listLayout.delegate = self;

    self.collectionView = [[NSCollectionView alloc] initWithFrame:self.scrollView.bounds];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = self.listLayout;
    self.collectionView.selectable = YES;
    self.collectionView.allowsEmptySelection = NO;
    [self.collectionView registerClass:[SidebarCollectionViewItem class] forItemWithIdentifier:@"SidebarItem"];
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
    [self.filterTokenField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(40, 16, 0, 16) excludingEdge:ALEdgeBottom];
    
    [self.scrollView autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(64, 0, 64, 0)];
    
    [self.previewSizeSlider autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 16, 16, 16) excludingEdge:ALEdgeTop];
    
    [divider autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [divider autoSetDimension:ALDimensionWidth toSize:1];
}

- (IBAction)toggleFileSection:(id)sender {
    self.fileSectionCollapsed = !self.fileSectionCollapsed;

    NSMutableSet *indexPaths = [[NSMutableSet alloc] init];
    NSInteger itemIndex = 0;
    for (SketchFile *file in self.sketchFiles) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:itemIndex inSection:1]];
        itemIndex = itemIndex + 1;
    }
    
    if(self.fileSectionCollapsed) {
        [self.collectionView.animator deleteItemsAtIndexPaths:indexPaths];
        
    }
    else {
        [self.collectionView.animator insertItemsAtIndexPaths:indexPaths];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 1) {
        if(self.fileSectionCollapsed) {
            return 0;
        }
        
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
        item.titleLabel.stringValue = @"All artboards";
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
            NSCollectionViewLayoutAttributes *layoutAttributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
            NSRect frame = layoutAttributes.frame;
            
            [self presentViewController:self.sizeFilterPicker asPopoverRelativeToRect:frame ofView:self.collectionView preferredEdge:NSRectEdgeMaxY behavior:NSPopoverBehaviorTransient];
        }
    }
}


@end
