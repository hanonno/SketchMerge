//
//  SketchFileCollectionController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileCollectionViewController.h"


@interface SketchFileCollectionViewController ()

@property (strong) PathFilter   *pathFilter;

@end


@implementation SketchFileCollectionViewController

- (id)initWithDirectory:(NSString *)directory {
    self = [super init];

    _indexer = [[SketchFileIndexer alloc] initWithDirectory:[directory stringByExpandingTildeInPath]];
    _indexer.delegate = self;
    
    _pageCollection = [[SketchPageCollection alloc] init];
    
    _pathFilter = [[PathFilter alloc] init];
    [_pageCollection addFilter:_pathFilter];
    
    return self;
}

- (void)showWindow:(id)sender {
    if(!self.window) {
        self.window = [NSWindow windowWithContentViewController:self];
        [self.window setTitleWithRepresentedFilename:self.indexer.directory];
//        self.window.titlebarAppearsTransparent = YES;
//        self.window.titleVisibility = NSWindowTitleHidden;
//        self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
        self.windowController = [[NSWindowController alloc] initWithWindow:self.window];
        self.windowController.windowFrameAutosaveName = self.indexer.directory;
    }

    [self.windowController showWindow:sender];
    [self.indexer startIndexing];
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480)];
    
    self.sidebarController = [[SidebarController alloc] init];
    self.sidebarController.delegate = self;
    [self.view addSubview:self.sidebarController.view];
    
    self.pageCollectionViewController = [[SketchPageCollectionViewController alloc] initWithPageCollection:self.pageCollection];
    [self.view addSubview:self.pageCollectionViewController.view];
    
    // Autolayout
    [self.sidebarController.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeRight];
    [self.sidebarController.view autoSetDimension:ALDimensionWidth toSize:240];
    
    [self.pageCollectionViewController.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
    [self.pageCollectionViewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:240];
}

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)file {
    [self.sidebarController addSketchFile:file];
    [self.pageCollection addPages:file.pages.allValues];
    [self.pageCollectionViewController reloadData];
}

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        SketchFile *file = [sidebarController sketchFileAtIndex:indexPath.item];
        [self.pathFilter setPath:file.fileURL.path];
        [self.pageCollectionViewController reloadData];
    }
}

@end
