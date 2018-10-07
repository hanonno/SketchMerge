//
//  SketchFileCollectionController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "FileBrowser.h"


#import "Filter.h"


@interface FileBrowser ()

@property (strong) KeywordFilter    *keywordFilter;
@property (strong) PathFilter       *pathFilter;
@property (strong) SizeFilter       *sizeFilter;

@end


@implementation FileBrowser

- (id)initWithDirectory:(NSString *)directory {
    self = [super init];

    _indexer = [[SketchFileIndexer alloc] initWithDirectory:[directory stringByExpandingTildeInPath]];
    _indexer.delegate = self;
    
    _assetCollection = [[AssetCollection alloc] initWithRealm:_indexer.realm];
    
    _pathFilter = [[PathFilter alloc] init];
    [_assetCollection addFilter:_pathFilter];
    
    _keywordFilter = [[KeywordFilter alloc] init];
    [_assetCollection addFilter:_keywordFilter];
    
    _sizeFilter = [[SizeFilter alloc] init];
    _sizeFilter.width = 1;
    _sizeFilter.height = 1;
    
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
    self.sidebarController.sizeFilterPicker.delegate = self;
    [self.view addSubview:self.sidebarController.view];
    
    self.assetBrowser = [[AssetBrowser alloc] initWithAssetCollection:self.assetCollection];
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

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)file {
    [self.sidebarController addSketchFile:file];
    [self.assetCollection reloadData];
    [self.assetBrowser.collectionView reloadData];
}

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarCollectionViewItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath {
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

- (void)updatePreviewSize {
    CGFloat ratio = self.sizeFilter.height / self.sizeFilter.width;
    CGFloat previewWidth = self.sidebarController.previewSizeSlider.floatValue;
    NSSize size = NSMakeSize(previewWidth, (previewWidth * ratio) + 24);
    self.assetBrowser.layout.itemSize = size;
}

- (void)changePreviewSize:(NSSlider *)sender {
    [self updatePreviewSize];
}

- (void)sizeFilterPicker:(SizeFilterPicker *)sizeFilterPicker didPickFilter:(SizeFilter *)filter {
    [self.sidebarController dismissViewController:sizeFilterPicker];
    
    self.sizeFilter = filter;
    
    [self.assetCollection replaceFilter:filter];
    [self.assetCollection reloadData];
    [self.assetBrowser.collectionView reloadData];
    
    [self updatePreviewSize];
}

@end
