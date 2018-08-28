//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"
#import "SketchDiffTool.h"
#import "SketchFilePlugin.h"
#import "CoreSync.h"
#import "CoreSyncTransaction.h"
#import "ArtboardGridViewController.h"

#import <PureLayout/PureLayout.h>


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;
@property (strong) ArtboardGridViewController   *artboardGridViewController;

@property (strong) SketchDiffTool               *sketchDiffTool;

@property (strong) NSURL                        *rootFileURL;
@property (strong) NSURL                        *changedFileURL;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.sketchDiffTool = [[SketchDiffTool alloc] init];
    
    self.artboardGridViewController = [[ArtboardGridViewController alloc] init];
    [self.window.contentView addSubview:self.artboardGridViewController.view];
    [self.artboardGridViewController.view autoPinEdgesToSuperviewEdges];
    
    NSButton *button = [NSButton buttonWithTitle:@"Reload" target:self action:@selector(reloadFile:)];
    
    [self.window.contentView addSubview:button];
}

- (IBAction)pickRootFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSModalResponse response = [openPanel runModal];
    
    if(response == NSModalResponseOK) {
        self.rootFileURL = openPanel.URLs[0];
    }
}

- (IBAction)pickChangedFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSModalResponse response = [openPanel runModal];
    
    if(response == NSModalResponseOK) {
        self.changedFileURL = openPanel.URLs[0];
    }
}


- (IBAction)reloadFile:(id)sender {
//    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
//    NSURL *rootFileURL = self.rootFileURL ? self.rootFileURL : [NSURL fileURLWithPath:@"/Users/hanno/Desktop/Root.sketch"];
//    NSURL *changedFileURL = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:@"/Users/hanno/Desktop/Root-A.sketch"];

//    NSURL *rootFileURL = self.rootFileURL ? self.rootFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"UW-Shipping" ofType:@"sketch"]];
//    NSURL *changedFileURL = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"UW-Shipping-B" ofType:@"sketch"]];

    NSURL *fileURLRoot = self.rootFileURL ? self.rootFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-Conflict-Root" ofType:@"sketch"]];
    NSURL *fileURLA = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-Conflict-A" ofType:@"sketch"]];
    NSURL *fileURLB = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-Conflict-B" ofType:@"sketch"]];
    NSURL *fileURLResult = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-B" ofType:@"sketch"]];
    
    SketchFile *fileRoot = [[SketchFile alloc] initWithFileURL:fileURLRoot];
    SketchFile *fileA = [[SketchFile alloc] initWithFileURL:fileURLA];
    SketchFile *fileB = [[SketchFile alloc] initWithFileURL:fileURLB];
    SketchFile *fileResult = [[SketchFile alloc] initWithFileURL:fileURLResult];

    [self.artboardGridViewController startLoading];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
//        SketchDiff *diff = [self.sketchDiffTool diffFromFile:fileRoot to:fileA];
//        NSArray *pages = diff.allOperations;
        
//        SketchArtboard *artboard = [[SketchArtboard alloc] init];
//
//        for (SketchPage *page in pages) {
//            [page insertLayer:artboard];
//            [self.sketchDiffTool generatePreviewsForArtboards:page.diff.allOperations];
//        }
        
        
//        SketchChangeSet *changeSet = [self.sketchDiffTool changesFromFile:fileRoot to:fileA];
//        
//        
//        SketchDiff *diffA = [self.sketchDiffTool diffFromFile:fileRoot to:fileA];
//        SketchDiff *diffB = [self.sketchDiffTool diffFromFile:fileRoot to:fileB];
//        
//        NSMutableSet *pageIds = [[NSMutableSet alloc] init];
//        [pageIds addObjectsFromArray:diffA.operationsById.allKeys];
//        [pageIds addObjectsFromArray:diffB.operationsById.allKeys];
//        
//        for (NSString *pageId in pageIds) {
//            SketchPage *pageA = [diffA operationWithId:pageId];
//            SketchPage *pageB = [diffB operationWithId:pageId];
//            
//            if(pageA != nil && pageB != nil) {
//                SketchMergeTool *mergeTool = [[SketchMergeTool alloc] initWithDiffA:pageA.diff diffB:pageB.diff];
//                
//                if(mergeTool.conflicts) {
//                    NSLog(@"Merge: %@", mergeTool);
//                }
//            }
//        }
//        
//        [fileRoot applyDiff:diffA];
//        [fileRoot applyDiff:diffB];
//
////        SketchArtboard *artboard = [[SketchArtboard alloc] init];
////        [fileRoot.pages.allValues.firstObject insertLayer:artboard];
//
//        [fileRoot writePages];
        
//        // Merge
//        NSLog(@"before page count %lu", (unsigned long)fileResult.pages.count);
//
//        [fileResult applyDiff:diff];
//
//        NSLog(@"after page count %lu", (unsigned long)fileResult.pages.count);
//
//        [fileResult writePages];
        
        SketchChangeSet *changeSetA = [self.sketchDiffTool changesFromFile:fileRoot to:fileA];
        SketchChangeSet *changeSetB = [self.sketchDiffTool changesFromFile:fileRoot to:fileB];
        
        SketchMergeTool *mergeTool = [[SketchMergeTool alloc] initWithChangeSetA:changeSetA changeSetB:changeSetB];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.artboardGridViewController.changeSet = changeSetA;
            [self.artboardGridViewController.collectionView reloadData];
            [self.artboardGridViewController finishLoading];
        });
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
