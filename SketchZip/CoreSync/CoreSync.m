// CoreSync.m
// Copyright (c) 2015 Janum Trivedi (http://janumtrivedi.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CoreSync.h"
#import "CoreSyncTransaction.h"
#import "NSMutableDictionary+CoreSync.h"
#import "NSArray+CoreSync.h"
#import "NSDictionary+CoreSync.h"

@implementation CoreSync

static const BOOL kShouldLog = NO;


#pragma mark - Diff API

+ (NSArray *)diffAsTransactions:(NSDictionary *)a :(NSDictionary *)b
{
    return [self diffDictionary:[a mutableDeepCopy] :[b mutableDeepCopy] root:@"" info:nil];
}

+ (NSArray *)diffAsDictionary:(NSDictionary *)a :(NSDictionary *)b
{
    NSMutableArray* transactions = [self diffDictionary:[a mutableDeepCopy] :[b mutableDeepCopy] root:@"" info:nil];
    
    return [self serializeTransactionsToArray:transactions];
}

+ (NSString *)diffAsJSON:(NSDictionary *)a :(NSDictionary *)b
{
    NSMutableArray* transactions = [self diffDictionary:[a mutableDeepCopy] :[b mutableDeepCopy] root:@"" info:nil];
    
    NSArray* toArray = [self serializeTransactionsToArray:transactions];

    return [self toJSON:toArray];
}


#pragma mark - Patch API

+ (NSDictionary *)patch:(NSDictionary *)a withTransactions:(NSArray *)transactions
{
    NSMutableDictionary* mutableA = [a mutableDeepCopy];
    for (CoreSyncTransaction* transaction in transactions) {
        [mutableA applyTransaction:transaction];
    }
    
    return mutableA;
}

+ (NSDictionary *)patch:(NSDictionary *)a withJSON:(NSString *)json
{
    NSDictionary* transactions = [NSMutableDictionary dictionaryWithJSON:json];
    
    NSMutableDictionary* mutableA = [a mutableDeepCopy];
    for (NSDictionary* transactionDict in transactions) {
        CoreSyncTransaction* transaction = [[CoreSyncTransaction alloc] initWithDictionary:transactionDict];
        [mutableA applyTransaction:transaction];
    }

    return mutableA;
}


#pragma mark - Private functions

+ (NSArray *)serializeTransactionsToArray:(NSMutableArray *)transactions
{
    NSMutableArray* transactionDictionaries = [[NSMutableArray alloc] init];
    for (CoreSyncTransaction* transaction in transactions) {
        [transactionDictionaries addObject:transaction.toDictionary];
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:transactionDictionaries options:0 error:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+ (CoreSyncTransaction *)editWithPath:(id)path value:(NSObject *)value info:(NSDictionary *)info
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeEdit
                                                        keyPath:path
                                                          value:value
                                                     info:info];
}

+ (CoreSyncTransaction *)deletionWithPath:(id)path info:(NSDictionary *)info
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeDeletion
                                                        keyPath:path
                                                          value:nil
                                                     info:info];
}

+ (CoreSyncTransaction *)additionWithPath:(id)path value:(NSObject *)value info:(NSDictionary *)info
{
    return [[CoreSyncTransaction alloc] initWithTransactionType:CSTransactionTypeAddition
                                                        keyPath:path
                                                          value:value
                                                     info:info];
}

//- (NSDictionary *)artboarInfoFromDictionary:(NSDictionary *)dictionary {
//
//}


#pragma mark - Core Diff Algorithm

+ (NSMutableArray *)diffDictionary:(NSMutableDictionary *)a :(NSMutableDictionary *)b root:(NSString *)root info:(NSDictionary *)info
{
    NSMutableArray* transactions = [[NSMutableArray alloc] init];
    
    NSArray* aKeys = [self sortedKeys:a];

    for (NSString* aKey in aKeys) {
        NSString* fullRoot = [NSString stringWithFormat:@"%@/%@", root, aKey];
        NSString *currentClass = a[@"_class"];
        
        if([currentClass isEqualToString:@"artboard"]) {
            info = @{
                @"artboardID": a[@"do_objectID"],
                @"artboardName": a[@"name"]
            };
        }

        if (! b[aKey]) {
            if (kShouldLog) {
                NSLog(@"Key: %@/%@ was removed", root, aKey);
            }
            
            if([currentClass isEqualToString:@"artboard"]) {
                CoreSyncTransaction* delete = [self deletionWithPath:fullRoot info:info];
                [transactions addObject:delete];
            }            
        }
        else {
            id aValue = a[aKey];
            id bValue = b[aKey];
            
            if ([self areEqual:aValue :bValue]) {
                if (kShouldLog) {
                    NSLog(@"Key: %@/%@ with value: %@ has not changed", root, aKey, a[aKey]);
                }
            }
            else {
                if ([aValue isKindOfClass:[NSDictionary class]]) {
                    [transactions addObjectsFromArray:[self diffDictionary:aValue :bValue root:fullRoot info:info]];
                }
                else if ([aValue isKindOfClass:[NSArray class]]) {
                    [transactions addObjectsFromArray:[self diffArray:aValue :bValue root:fullRoot info:info]];
                }
                else {
                    if (kShouldLog) {
                        NSLog(@"Key: %@/%@ has changed: %@ -> %@", root, aKey, aValue, bValue);
                    }
                    
                    CoreSyncTransaction* edit = [self editWithPath:fullRoot value:bValue info:info];
                    [transactions addObject:edit];
                }
            }
        }
    }
    
    NSArray* bKeys = [self sortedKeys:b];
    for (NSString* bKey in bKeys) {
        if (! a[bKey]) {
            if (kShouldLog) {
                NSLog(@"Key: %@/%@ was added", root, bKey);
            }
            
            NSString* fullRoot = [NSString stringWithFormat:@"%@/%@", root, bKey];
            
            if([b[@"_class"] isEqualToString:@"artboard"]) {
                info = @{
                    @"artboardID": b[@"do_objectID"],
                    @"artboardName": b[@"name"]
                };
            }

            CoreSyncTransaction* add = [self additionWithPath:fullRoot value:b[bKey] info:info];
            [transactions addObject:add];
        }
    }
    
    return transactions;
}

+ (NSMutableArray *)diffArray:(NSArray *)a :(NSArray *)b root:(NSString *)root info:(NSDictionary *)info
{
    NSMutableArray* transactions = [[NSMutableArray alloc] init];
    
    if ([a isEqualToArray:b]) {
        return transactions;
    }
    
    NSUInteger min = MIN(a.count, b.count);
    NSUInteger max = MAX(a.count, b.count);
    
    for (NSUInteger i = 0; i < min; ++i) {
        if (! [self areEqual:a[i] :b[i]]) {
            
            NSNumber* index = [NSNumber numberWithInteger:i];
            NSString* fullPath = [NSString stringWithFormat:@"%@/%@", root, index];

            if ([a[i] isKindOfClass:[NSDictionary class]]) {
                if([a[i][@"_class"] isEqualToString:@"artboard"]) {
                    info = @{
                         @"artboardID": a[i][@"do_objectID"],
                         @"artboardName": a[i][@"name"]
                     };
                }

                [transactions addObjectsFromArray:[self diffDictionary:a[i] :b[i] root:fullPath info:info]];
            }
            else if ([a[i] isKindOfClass:[NSArray class]]) {
                [transactions addObjectsFromArray:[self diffArray:a :b root:fullPath info:info]];
            }
            else {
                if (kShouldLog) {
                    NSLog(@"Key: %@/%lu element changed: %@ -> %@", root, i, a[i], b[i]);
                }
                
                CoreSyncTransaction* edit = [self editWithPath:fullPath value:b[i] info:info];
                [transactions addObject:edit];
            }
        }
    }

    for (NSUInteger i = min; i < max; ++i) {
        NSNumber* index = [NSNumber numberWithInteger:i];
        NSString* fullPath = [NSString stringWithFormat:@"%@/%@", root, index];
        
        if (b.count > a.count) {
            // Addition
            if (kShouldLog) {
                NSLog(@"Key: %@/%lu element was added: %@", root, i, b[i]);
            }
            
            if([b[i][@"_class"] isEqualToString:@"artboard"]) {
                info = @{
                     @"artboardID": b[i][@"do_objectID"],
                     @"artboardName": b[i][@"name"]
                 };
            }

            CoreSyncTransaction* addition = [self additionWithPath:fullPath value:b[i] info:info];
            [transactions addObject:addition];
        }
        else {
            // Deletion
            if (kShouldLog) {
                NSLog(@"Key: %@/%lu element was removed: %@", root, i, a[i]);   
            }
            
            if([a[i][@"_class"] isEqualToString:@"artboard"]) {
                info = @{
                         @"artboardID": a[i][@"do_objectID"],
                         @"artboardName": a[i][@"name"]
                 };
            }
            
            CoreSyncTransaction* deletion = [self deletionWithPath:fullPath info:info];
            [transactions addObject:deletion];
        }
    }
    
    return transactions;
}

+ (BOOL)areEqual:(NSObject *)a :(NSObject *)b
{
    if (! [self areEqualType:a :b]) {
        return NO;
    }
    
    return [self areEqualValue:a :b];
}

+ (BOOL)areEqualValue:(NSObject *)a :(NSObject *)b
{
    if ([a isKindOfClass:[NSString class]]) {
        return [(NSString *)a isEqualToString:(NSString *)b];
    }
    else if ([a isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)a isEqualToNumber:(NSNumber *)b];
    }
    else if ([a isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)a isEqualToDictionary:(NSDictionary *)b];
    }
    else if ([a isKindOfClass:[NSArray class]]) {
        return [(NSArray *)a isEqualToArray:(NSArray *)b];
    }
    
    return NO;
}

+ (BOOL)areEqualType:(NSObject *)a :(NSObject *)b
{
    return [a class] == [b class];
}

+ (NSArray *)sortedKeys:(NSDictionary *)dictionary
{
    return [dictionary.allKeys sortedArrayUsingComparator:^(id aK, id bK) {
        return [aK compare:bK options:NSNumericSearch];
    }];
}

+ (NSString *)toJSON:(id)JSONObject
{
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
