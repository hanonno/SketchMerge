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
#import "SketchPageCollection.h"

#import "SidebarController.h"
#import "SketchPageCollectionViewController.h"
#import "AssetBrowser.h"


@interface SketchFileCollectionViewController : NSViewController <SketchFileIndexerDelegate, SidebarControllerDelegate>

@property (strong) NSWindow                                 *window;
@property (strong) NSWindowController                       *windowController;

@property (strong) SidebarController                        *sidebarController;
@property (strong) SketchPageCollectionViewController       *pageCollectionViewController;
@property (strong) AssetBrowser                        *itemBrowser;

@property (strong) SketchFileIndexer                        *indexer;
@property (strong) SketchPageCollection                     *pageCollection;

- (void)showWindow:(id)sender;

- (id)initWithDirectory:(NSString *)directory;

@end
