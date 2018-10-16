//
//  Cahier.m
//  Cahier
//
//  Created by Hanno ten Hoor on 16/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "Cahier.h"


#import "CahierViewController.h"


@implementation Cahier

@synthesize viewController = _viewController;

+ (NSArray *)ignoredProperties {
    return @[@"viewController"];
}

+ (Cahier *)cahierForDirectoryWithPath:(NSString *)directoryPath {
    RLMResults *cahiers = [Cahier objectsWhere:@"directory == %@", directoryPath];
    
    if(cahiers.count > 1) {
        NSLog(@"Error: multiple cahiers for the same directory...");
    }
    
    Cahier *cahier = [cahiers firstObject];
    
    if(cahier == nil) {
        cahier = [[Cahier alloc] init];
        cahier.directory = directoryPath;
        cahier.sizePresetName = @"Any device";
        cahier.zoomFactor = 1.0;
        cahier.windowVisible = YES;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:cahier];
        [realm commitWriteTransaction];
    }
    
    return cahier;
}

- (CahierViewController *)viewController {
    if(!_viewController) {
        _viewController = [[CahierViewController alloc] initWithCahier:self];
    }
    
    return _viewController;
}

@end
