//
//  Matrix.m
//  BoxOffice
//
//  Created by Cyrus Najmabadi on 5/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Matrix.h"


@implementation Matrix

@synthesize array;

- (void) dealloc
{
    self.array = nil;
    [super dealloc];
}

+ (Matrix*) matrixWithX:(NSInteger) x 
                      Y:(NSInteger) y
{
    return [[[Matrix alloc] initWithX:x Y:y] autorelease];
}

- (id) initWithX:(NSInteger) x 
               Y:(NSInteger) y
{
    if (self = [super init])
    {
        self.array = [NSMutableArray array];
        
        for (int i = 0; i < x; i++)
        {
            NSMutableArray* inner = [NSMutableArray array];
            [array addObject:inner];
            
            for (int j = 0; j < y; j++)
            {
                [inner addObject:[NSNumber numberWithInt:0]];
            }
        }
    }
    
    return self;
}

- (NSInteger) getX:(NSInteger) x
                 Y:(NSInteger) y
{
    return [[[array objectAtIndex:x] objectAtIndex:y] intValue];
}

- (void) setX:(NSInteger) x
            Y:(NSInteger) y
        value:(NSInteger) value
{
    [[array objectAtIndex:x] replaceObjectAtIndex:y withObject:[NSNumber numberWithInt:value]];
}

@end
