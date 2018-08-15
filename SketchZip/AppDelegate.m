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

    NSURL *fileURLRoot = self.rootFileURL ? self.rootFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-Root" ofType:@"sketch"]];
    NSURL *fileURLA = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-A" ofType:@"sketch"]];
    NSURL *fileURLB = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-B" ofType:@"sketch"]];
    NSURL *fileURLResult = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sketch-Result" ofType:@"sketch"]];
    
    SketchFile *fileRoot = [SketchFile readFromURL:fileURLRoot];
    SketchFile *fileA = [SketchFile readFromURL:fileURLA];
    SketchFile *fileB = [SketchFile readFromURL:fileURLB];
    SketchFile *fileResult = [SketchFile readFromURL:fileURLResult];
    
    [self.artboardGridViewController startLoading];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        SketchDiff *diff = [self.sketchDiffTool diffFromFile:fileRoot to:fileA];
        NSArray *pages = diff.allOperations;
        SketchPage *page = pages.firstObject;
        
        [self.sketchDiffTool generatePreviewsForArtboards:page.operations];

        // Merge
        NSLog(@"before page count %lu", (unsigned long)fileRoot.pages.count);
        
        [fileResult applyDiff:diff];
        
        NSLog(@"after page count %lu", (unsigned long)fileRoot.pages.count);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.artboardGridViewController.pages = pages;
            [self.artboardGridViewController.collectionView reloadData];
            [self.artboardGridViewController finishLoading];
        });
    });
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
