//
//  Matrix.h
//  BoxOffice
//
//  Created by Cyrus Najmabadi on 5/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface Matrix : NSObject {
    NSMutableArray* array;
}

- (id) initWithX:(NSInteger) x 
               Y:(NSInteger) y;

- (NSInteger) getX:(NSInteger) x
                 Y:(NSInteger) y;

- (void) setX:(NSInteger) x
            Y:(NSInteger) y
        value:(NSInteger) value;

@end
