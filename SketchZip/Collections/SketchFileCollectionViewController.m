//
//  SketchFileCollectionController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchFileCollectionViewController.h"


#import "Filter.h"


@interface SketchFileCollectionViewController ()

@property (strong) KeywordFilter    *keywordFilter;
@property (strong) PathFilter       *pathFilter;

@end


@implementation SketchFileCollectionViewController

- (id)initWithDirectory:(NSString *)directory {
    self = [super init];

    _indexer = [[SketchFileIndexer alloc] initWithDirectory:[directory stringByExpandingTildeInPath]];
    _indexer.delegate = self;
    
    _assetCollection = [[AssetCollection alloc] initWithRealm:_indexer.realm];
    
    _pathFilter = [[PathFilter alloc] init];
    [_assetCollection addFilter:_pathFilter];
    
    _keywordFilter = [[KeywordFilter alloc] init];
    [_assetCollection addFilter:_keywordFilter];
    
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
    
    self.assetBrowser = [[AssetCollectionBrowser alloc] initWithAssetCollection:self.assetCollection];
    [self.view addSubview:self.assetBrowser.view];
    
    // Autolayout
    [self.sidebarController.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeRight];
    [self.sidebarController.view autoSetDimension:ALDimensionWidth toSize:240];
    
    [self.assetBrowser.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
    [self.assetBrowser.view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:240];
    
    self.sidebarController.filterTokenField.delegate = self;
    [self.sidebarController.previewSizeSlider setTarget:self];
    [self.sidebarController.previewSizeSlider setAction:@selector(changePreviewSize:)];
}

- (void)changePreviewSize:(NSSlider *)sender {
    self.assetBrowser.layout.itemSize = NSMakeSize(sender.floatValue, sender.floatValue);
}

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)file {
    [self.sidebarController addSketchFile:file];
    [self.assetBrowser.collectionView reloadData];
}

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        SketchFile *file = [sidebarController sketchFileAtIndex:indexPath.item];
        [self.pathFilter setPath:file.fileURL.path];
        [self.assetCollection reloadData];
        [self.assetBrowser.collectionView reloadData];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTokenField *tokenField = (NSTokenField *)[notification object];
    NSString *filterString = tokenField.stringValue;
    NSLog(@"Keyword: %@", filterString);
    
    self.keywordFilter.keywords = filterString;
    [self.assetCollection reloadData];
    [self.assetBrowser.collectionView reloadData];
}

@end
