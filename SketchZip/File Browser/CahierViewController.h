//
//  SketchFileCollectionController.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 25/09/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>


#import "Cahier.h"
#import "SketchFileIndexer.h"
#import "SidebarController.h"
#import "FilterBarController.h"
#import "AssetBrowser.h"


@interface CahierViewController : NSViewController <SketchFileIndexerDelegate, SidebarControllerDelegate, FilterBarControllerDelegate, AssetCollectionDelegate, NSWindowDelegate>

@property (strong) NSWindow             *window;
@property (strong) NSWindowController   *windowController;

@property (strong) SidebarController    *sidebarController;

@property (strong) FilterBarController  *filterBarController;
@property (strong) AssetBrowser         *assetBrowser;

@property (strong) Cahier               *cahier;
@property (strong) SketchFileIndexer    *indexer;
@property (strong) AssetCollection      *assetCollection;

- (void)showWindow:(id)sender;

- (id)initWithCahier:(Cahier *)cahier;

- (IBAction)showAssets:(id)sender;
- (IBAction)showFavorites:(id)sender;

- (IBAction)viewAsGrid:(id)sender;
- (IBAction)viewAsGallery:(id)sender;

@end
