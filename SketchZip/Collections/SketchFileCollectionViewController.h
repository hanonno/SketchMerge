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
#import "AssetBrowser.h"


@interface SketchFileCollectionViewController : NSViewController <SketchFileIndexerDelegate, SidebarControllerDelegate, NSTokenFieldDelegate>

@property (strong) NSWindow                                 *window;
@property (strong) NSWindowController                       *windowController;

@property (strong) SidebarController                        *sidebarController;
@property (strong) AssetBrowser                             *assetBrowser;

@property (strong) SketchFileIndexer                        *indexer;
@property (strong) AssetCollection                          *assetCollection;

- (void)showWindow:(id)sender;

- (id)initWithDirectory:(NSString *)directory;

@end
