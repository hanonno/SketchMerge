//
//  GalleryLayout.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 16/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "GalleryLayout.h"


@implementation GalleryLayoutSection

- (instancetype)init {
    self = [super init];
 
    _name = @"Hello";
    _assetLayoutAttributes = [[NSMutableArray alloc] init];
    
    return self;
}


@end


@interface GalleryLayout ()

@property (assign) CGSize   contentSize;
@property (strong) NSArray  *galleryLayoutAttributes;

@end


@implementation GalleryLayout

- (instancetype)initWithAssetCollection:(AssetCollection *)assetCollection {
    self = [super init];
    
    _assetCollection = assetCollection;
    _sections = nil;
    _galleryLayoutAttributes = nil;
    
    return self;
}

- (GalleryLayoutSection *)sectionAtIndex:(NSInteger)index {
    return [self.sections objectAtIndex:index];
}


- (void)prepareLayout {
    CGPoint origin = CGPointMake(32, 32);
    CGRect contentFrame = CGRectZero;
    NSUInteger itemIndex = 0, sectionIndex = 0;

    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSMutableArray *galleryLayoutAttributes = [[NSMutableArray alloc] init];
    
    for(sectionIndex = 0; sectionIndex < self.assetCollection.numberOfGroups; sectionIndex++) {
        AssetGroup *group = [self.assetCollection groupAtIndex:sectionIndex];
        GalleryLayoutSection *section = [[GalleryLayoutSection alloc] init];
        
        for(itemIndex = 0; itemIndex < group.assets.count; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            NSCollectionViewLayoutAttributes *assetLayoutAttributes = [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath:indexPath];
            Asset *asset = [self.assetCollection assetAtIndexPath:indexPath];
            
            assetLayoutAttributes.frame = CGRectMake(origin.x, origin.y, asset.width, asset.height + 24);
            [section.assetLayoutAttributes addObject:assetLayoutAttributes];
            [galleryLayoutAttributes addObject:assetLayoutAttributes];

            origin.x = origin.x + asset.width + 32;
            contentFrame = CGRectUnion(contentFrame, assetLayoutAttributes.frame);
        }
        
        [sections addObject:section];
    }

    self.sections = sections;
    self.galleryLayoutAttributes = galleryLayoutAttributes;
    self.contentSize = CGSizeMake(contentFrame.size.width + 32, contentFrame.size.height + 32);
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSArray*)layoutAttributesForElementsInRect:(NSRect)rect {
    return self.galleryLayoutAttributes;
}

- (NSCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self sectionAtIndex:indexPath.section] assetLayoutAttributes] objectAtIndex:indexPath.item];
}

//- (BOOL)shouldInvalidateLayoutForBoundsChange:(NSRect)newBounds {
//    return YES;
//}

@end

