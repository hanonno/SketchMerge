//
//  SketchFileCollectionController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "SketchFileIndexer.h"
#import "SidebarController.h"
#import "FilterListController.h"
#import "FilterBarController.h"
#import "AssetBrowser.h"


@interface FileBrowser : NSViewController <SketchFileIndexerDelegate, SidebarControllerDelegate, SizeFilterPickerDelegate, NSTokenFieldDelegate>

@property (strong) NSWindow                                 *window;
@property (strong) NSWindowController                       *windowController;

@property (strong) FilterListController                     *filterListController;
@property (strong) SidebarController                        *sidebarController;

@property (strong) FilterBarController                      *filterBarController;
@property (strong) AssetBrowser                             *assetBrowser;

@property (strong) SketchFileIndexer                        *indexer;
@property (strong) AssetCollection                          *assetCollection;

- (void)showWindow:(id)sender;

- (id)initWithDirectory:(NSString *)directory;

- (IBAction)showAssets:(id)sender;
- (IBAction)showFavorites:(id)sender;

@end
