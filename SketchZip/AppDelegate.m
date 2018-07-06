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


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;
@property (strong) ArtboardGridViewController   *artboardGridViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    self.artboardGridViewController = [[ArtboardGridViewController alloc] init];
    [self.window.contentView addSubview:self.artboardGridViewController.view];
    
    NSButton *button = [NSButton buttonWithTitle:@"Reload" target:self action:@selector(reloadFile:)];
    
    [self.window.contentView addSubview:button];
    
}

- (IBAction)reloadFile:(id)sender {
    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
    NSURL *changedFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-B" ofType:@"sketch"]];
    
    [self.artboardGridViewController loadChangesFromFile:rootFileURL to:changedFileURL];
}

- (void)test2 {
    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
    NSURL *changedFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-B" ofType:@"sketch"]];
    
    SketchDiffTool *sketchFile = [[SketchDiffTool alloc] init];
    
    NSDictionary *pages = [sketchFile _pagesFromFileAtURL:rootFileURL];
    NSArray *transactions = [sketchFile diffFromFile:rootFileURL to:changedFileURL];
    
    for (CoreSyncTransaction *transaction in transactions) {
        //        NSLog(@"%@", transaction.keyPath);
        
        NSLog(@"page: %@ > layer index: %@", transaction.pageID, transaction.artboardID);
        
        SketchFilePlugin *plugin = [[SketchFilePlugin alloc] init];
        
        NSImage *image = [plugin imageForArtboardWithID:transaction.artboardID inFileWithURL:rootFileURL maxSize:CGSizeMake(1280, 1280)];
        
    }
    
    //    sketchtool export artboards path/to/document.sketch --formats=jpg,png,svg
    //    sketchtool export artboards path/to/document.sketch --scales=1,2
    
    //    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
    //    NSURL *myFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-A" ofType:@"sketch"]];
    //    NSURL *theirFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-B" ofType:@"sketch"]];
    //
    //    SketchFile *sketchFile = [[SketchFile alloc] init];
    //
    //    NSArray *myDiff = [sketchFile diffFromFile:rootFileURL to:myFileURL];
    //    NSArray *theirDiff = [sketchFile diffFromFile:rootFileURL to:theirFileURL];
    //
    //    NSDictionary *myTransactions = @{ @"transactions": myDiff };
    //    NSDictionary *theirTransactios = @{ @"transactions": theirDiff };
    //
    //    NSArray *diff = [CoreSync diffAsTransactions:myTransactions :theirTransactios];
    
    //    NSDictionary *originalArtboards = [sketchFile artboardsForFileWithURL:originalFileURL];
    //    NSDictionary *newArtboards = [sketchFile artboardsForFileWithURL:newFileURL];
    //
    //    if([originalArtboards isEqualToDictionary:newArtboards]) {
    //        NSLog(@"Equal!");
    //    }
    //
    //    NSArray* JSONChanges = [CoreSync diffAsTransactions:originalArtboards :newArtboards];
    //    NSLog(@"%@", JSONChanges);

}

- (void)test {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestFile1" ofType:@"sketch"];
    
    NSString *destination = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TestFile1"];
    NSString *rezipped = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TestFile2"];
    
    [SSZipArchive unzipFileAtPath:path toDestination:destination];
    [SSZipArchive createZipFileAtPath:rezipped withContentsOfDirectory:destination];
    
    NSLog(@"Destination: %@", destination);
    NSLog(@"Rezipped: %@", rezipped);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
