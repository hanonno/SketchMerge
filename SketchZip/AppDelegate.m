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

@property (strong) NSURL                        *rootFileURL;
@property (strong) NSURL                        *changedFileURL;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
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

    NSURL *rootFileURL = self.rootFileURL ? self.rootFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Version-1" ofType:@"sketch"]];
    NSURL *changedFileURL = self.changedFileURL ? self.changedFileURL : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Version-6" ofType:@"sketch"]];
    
    [self.artboardGridViewController loadChangesFromFile:rootFileURL to:changedFileURL];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
