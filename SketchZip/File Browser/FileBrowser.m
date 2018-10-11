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
@property (strong) FavoriteFilter   *favoriteFilter;

@end


@implementation FileBrowser

- (id)initWithDirectory:(NSString *)directory {
    self = [super init];

    _indexer = [[SketchFileIndexer alloc] initWithDirectory:[directory stringByExpandingTildeInPath]];
    _indexer.delegate = self;
    
    _assetCollection = [[AssetCollection alloc] initWithRealm:_indexer.realm];
    [_assetCollection addDelegate:self];
    
    _pathFilter = [[PathFilter alloc] init];
    [_assetCollection addFilter:_pathFilter];
    
    _keywordFilter = [[KeywordFilter alloc] init];
    [_assetCollection addFilter:_keywordFilter];
    
    _sizeFilter = [[SizeFilter alloc] init];
    _sizeFilter.width = 1;
    _sizeFilter.height = 1;
    
    _favoriteFilter = [[FavoriteFilter alloc] init];
    _favoriteFilter.enabled = NO;
    [_assetCollection addFilter:_favoriteFilter];
    
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
    
    self.filterListController = [[FilterListController alloc] init];
//    [self.view addSubview:self.filterListController.view];
    
    self.sidebarController = [[SidebarController alloc] init];
    self.sidebarController.delegate = self;
    [self.view addSubview:self.sidebarController.view];
    
    self.filterBarController = [[FilterBarController alloc] initWithAssetCollection:self.assetCollection];
    self.filterBarController.delegate = self;
    [self.view addSubview:self.filterBarController.view];
    
    self.assetBrowser = [[AssetBrowser alloc] initWithAssetCollection:self.assetCollection];
    [self.view addSubview:self.assetBrowser.view];
    
    NSView *sidebar = self.sidebarController.view;
    
    // Autolayout
    [sidebar autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeRight];
    [sidebar autoSetDimension:ALDimensionWidth toSize:240];
    
    [self.filterBarController.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 240, 0, 0) excludingEdge:ALEdgeTop];
    [self.filterBarController.view autoSetDimension:ALDimensionHeight toSize:32];
    
    [self.assetBrowser.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 32, 0) excludingEdge:ALEdgeLeft];
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

- (void)changePreviewSize:(NSSlider *)sender {
    [self.assetBrowser setZoomFactor:sender.floatValue];
}

- (IBAction)showAssets:(id)sender {
    self.favoriteFilter.enabled = NO;
    [self.assetCollection reloadData];
//    [self.assetBrowser.collectionView reloadData];
}

- (IBAction)showFavorites:(id)sender {
    self.favoriteFilter.enabled = YES;
    [self.assetCollection reloadData];
//    [self.assetBrowser.collectionView reloadData];
}

@end
