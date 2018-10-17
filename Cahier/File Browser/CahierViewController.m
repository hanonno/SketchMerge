//
//  SketchFileCollectionController.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "CahierViewController.h"


#import "Filter.h"


@interface CahierViewController ()

@property (strong) KeywordFilter    *keywordFilter;
@property (strong) PathFilter       *pathFilter;
@property (strong) SizeFilter       *sizeFilter;
@property (strong) FavoriteFilter   *favoriteFilter;

@end


@implementation CahierViewController

- (id)initWithCahier:(Cahier *)cahier {
    self = [super init];

    _cahier = cahier;
    
    _indexer = [[SketchFileIndexer alloc] initWithDirectory:[cahier.directory stringByExpandingTildeInPath]];
    _indexer.delegate = self;
    
    _assetCollection = [[AssetCollection alloc] initWithRealm:_indexer.realm];
//    [_assetCollection replaceFilter:<#(Filter *)#>]
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
//        [self.window setTitleWithRepresentedFilename:self.indexer.directory];
        self.window.titlebarAppearsTransparent = YES;
        self.window.delegate = self;
        self.window.titleVisibility = NSWindowTitleHidden;
        self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
//        self.window.styleMask |= NSWindowStyleMaskUnifiedTitleAndToolbar;
        self.windowController = [[NSWindowController alloc] initWithWindow:self.window];
        self.windowController.windowFrameAutosaveName = self.indexer.directory;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
    }
    
    [self.windowController showWindow:sender];
    [self.indexer startIndexing];
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1200, 800)];
        
    self.sidebarController = [[SidebarController alloc] init];
    self.sidebarController.delegate = self;
    [self.view addSubview:self.sidebarController.view];
    
    self.browserHeaderController = [[BrowserHeaderController alloc] initWithAssetCollection:self.assetCollection];
    self.browserHeaderController.zoomFactorSlider.floatValue = self.cahier.zoomFactor;
    self.browserHeaderController.zoomFactorSlider.target = self;
    self.browserHeaderController.zoomFactorSlider.action = @selector(changePreviewSize:);
    [self.view addSubview:self.browserHeaderController.view];
    
    self.assetBrowser = [[AssetBrowser alloc] initWithAssetCollection:self.assetCollection];
    [self.view addSubview:self.assetBrowser.view];
    [self addChildViewController:self.assetBrowser];
    
    NSView *sidebar = self.sidebarController.view;
    
    // Autolayout
    CGFloat headerHeight = 67+8+19+7;
    CGFloat sidebarWidth = 240;
    
    [sidebar autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeRight];
    [sidebar autoSetDimension:ALDimensionWidth toSize:sidebarWidth];
    
    [self.browserHeaderController.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(0, sidebarWidth, 0, 0) excludingEdge:ALEdgeBottom];
    [self.browserHeaderController.view autoSetDimension:ALDimensionHeight toSize:headerHeight];
    
    [self.assetBrowser.view autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(headerHeight, 0, 0, 0) excludingEdge:ALEdgeLeft];
    [self.assetBrowser.view autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:sidebarWidth];
    
    // Setup default zoom level
    [self changePreviewSize:self.browserHeaderController.zoomFactorSlider];
}

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer willIndexFile:(SketchFile *)file {
    [self.sidebarController addSketchFile:file];
    [self.assetCollection reloadData];
    [self.assetBrowser.collectionView reloadData];
}

- (void)sketchFileIndexer:(SketchFileIndexer *)fileIndexer didIndexFile:(SketchFile *)file {
    [self.assetCollection reloadData];
}

- (void)sidebarController:(SidebarController *)sidebarController didSelectItem:(SidebarCollectionViewItem *)sidebarItem atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        SketchFile *file = [sidebarController sketchFileAtIndex:indexPath.item];

        self.pathFilter.path = file.fileURL.path;
        self.favoriteFilter.enabled = NO;
        self.browserHeaderController.titleLabel.stringValue = [file.fileURL.path.lastPathComponent stringByDeletingPathExtension];
        [self.assetCollection reloadData];
        [self.assetBrowser.collectionView reloadData];
    }
    else if(indexPath.section == 0) {
        if(indexPath.item == 0) {
            self.pathFilter.path = self.indexer.directory;
            self.favoriteFilter.enabled = NO;
            [self.assetCollection reloadData];
            self.browserHeaderController.titleLabel.stringValue = self.indexer.directory.lastPathComponent;
        }
        if(indexPath.item == 1) {
            self.favoriteFilter.enabled = YES;
            self.browserHeaderController.titleLabel.stringValue = @"Favorites";
            [self.assetCollection reloadData];
        }
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
    float zoomFactor = sender.floatValue;
    
    [self.assetBrowser setZoomFactor:zoomFactor];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.cahier.zoomFactor = zoomFactor;
    [realm commitWriteTransaction];
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

- (IBAction)viewAsGrid:(id)sender {
    [self.assetBrowser.collectionView.animator setCollectionViewLayout:self.assetBrowser.layout];
}

- (IBAction)viewAsGallery:(id)sender {
    [self.assetBrowser.collectionView.animator setCollectionViewLayout:self.assetBrowser.galleryLayout];
}

- (void)filterBarController:(FilterBarController *)filterBarController didUpdateFilter:(Filter *)filter {
    
}

- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection {
    
}

- (void)assetCollectionDidUpdate:(AssetCollection *)assetCollection filter:(Filter *)filter {
    if([filter isKindOfClass:[SizeFilter class]]) {
        [self.cahier.realm beginWriteTransaction];
        self.cahier.sizePresetName = [(SizeFilter *)filter presetName];
        [self.cahier.realm commitWriteTransaction];
    }
}

@end
