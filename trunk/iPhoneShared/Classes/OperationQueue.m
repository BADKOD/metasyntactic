// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "OperationQueue.h"

#import "MutablePointerSet.h"
#import "Operation.h"
#import "Operation1.h"
#import "Operation2.h"

@interface OperationQueue()
@property (retain) NSOperationQueue* queue;
//@property (retain) MutablePointerSet* operations;
@property (retain) NSMutableArray* boundedOperations;
@property (retain) NSLock* dataGate;
@end


@implementation OperationQueue

static OperationQueue* operationQueue = nil;

@synthesize queue;
//@synthesize operations;
@synthesize boundedOperations;
@synthesize dataGate;

- (void) dealloc {
    self.queue = nil;
    //self.operations = nil;
    self.boundedOperations = nil;
    self.dataGate = nil;

    [super dealloc];
}


- (void) addOperation:(Operation*) operation {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(addOperation:) withObject:operation waitUntilDone:NO];
        return;
    }
    
    [dataGate lock];
    {
        //[operations addObject:operation];
        [queue addOperation:operation];
        
        if (operation.queuePriority >= Priority) {
            priorityOperationsCount++;
        }
    }
    [dataGate unlock];
}


- (void) restart:(Operation*) operationToKill {
    [dataGate lock];
    {
        //MutablePointerSet* oldOperations = [[operations retain] autorelease];
        //[oldOperations removeObject:operationToKill];
        
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        //queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        queue.maxConcurrentOperationCount = 1;
        
        //self.operations = [MutablePointerSet set];
        self.boundedOperations = [NSMutableArray array];
        priorityOperationsCount = 0;
        
        //for (NSValue* value in oldOperations.mutableSet) {
        //    id op = (id)value.pointerValue;
        //    [self addOperation:op];
        //}
    }
    [dataGate unlock];
}


- (void) restart {
    [self restart:nil];
}


- (id) init {
    if (self = [super init]) {
        self.dataGate = [[[NSLock alloc] init] autorelease];
        
        [self restart];
    }

    return self;
}


+ (OperationQueue*) operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[OperationQueue alloc] init];
    }

    return operationQueue;
}


- (Operation*) performSelector:(SEL) selector
                      onTarget:(id) target
                          gate:(id<NSLocking>) gate
                      priority:(QueuePriority) priority {
    Operation* operation = [Operation operationWithTarget:target
                                                 selector:selector
                                           operationQueue:self
                                                isBounded:NO
                                                     gate:gate
                                                 priority:priority];
    [self addOperation:operation];
    return operation;
}


- (Operation1*) performSelector:(SEL) selector
                       onTarget:(id) target
                     withObject:(id) object
                           gate:(id<NSLocking>) gate
                       priority:(QueuePriority) priority {
    Operation1* operation = [Operation1 operationWithTarget:target
                                                   selector:selector
                                                   argument:object
                                             operationQueue:self
                                                  isBounded:NO
                                                       gate:gate
                                                   priority:priority];
    [self addOperation:operation];
    return operation;
}


- (Operation2*) performSelector:(SEL) selector
                       onTarget:(id) target
                     withObject:(id) object1
                     withObject:(id) object2
                           gate:(id<NSLocking>) gate
                       priority:(QueuePriority) priority {
    Operation2* operation = [Operation2 operationWithTarget:target
                                                   selector:selector
                                                   argument:object1
                                                   argument:object2
                                             operationQueue:self
                                                  isBounded:NO
                                                       gate:gate
                                                   priority:priority];
    [self addOperation:operation];
    return operation;
}


const NSInteger MAX_BOUNDED_OPERATIONS = 4;
- (void) addBoundedOperation:(Operation*) operation {
    [dataGate lock];
    {
        if (boundedOperations.count > MAX_BOUNDED_OPERATIONS) {
            // too many operations.  cancel the oldest one.
            Operation* staleOperation = [boundedOperations objectAtIndex:0];
            [staleOperation cancel];

            [boundedOperations removeObjectAtIndex:0];
        }

        // make the last priority operation dependent on this one.
        //if (boundedOperations.count > 0) {
        //    [(NSOperation*)boundedOperations.lastObject addDependency:operation];
        //}

        [boundedOperations addObject:operation];
    }
    [dataGate unlock];

    [self addOperation:operation];
}


- (Operation*) performBoundedSelector:(SEL) selector onTarget:(id) target gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation* operation = [Operation operationWithTarget:target
                                                 selector:selector
                                           operationQueue:self
                                                isBounded:YES
                                                     gate:gate
                                                 priority:priority];
    [self addBoundedOperation:operation];
    return operation;
}


- (Operation1*) performBoundedSelector:(SEL) selector
                              onTarget:(id) target
                            withObject:(id) object
                                  gate:(id<NSLocking>) gate
                              priority:(QueuePriority) priority {
    Operation1* operation = [Operation1 operationWithTarget:target
                                                   selector:selector
                                                   argument:object
                                             operationQueue:self
                                                  isBounded:YES
                                                       gate:gate
                                                   priority:priority];
    [self addBoundedOperation:operation];
    return operation;
}


- (Operation2*) performBoundedSelector:(SEL) selector
                              onTarget:(id) target
                            withObject:(id) object1
                            withObject:(id) object2
                                  gate:(id<NSLocking>) gate
                              priority:(QueuePriority) priority {
    Operation2* operation = [Operation2 operationWithTarget:target
                                                   selector:selector
                                                   argument:object1
                                                   argument:object2
                                             operationQueue:self
                                                  isBounded:YES
                                                       gate:gate
                                                   priority:priority];
    [self addBoundedOperation:operation];
    return operation;
}


- (void) onAfterBoundedOperationCompleted:(Operation*) operation {
    [dataGate lock];
    {
        [boundedOperations removeObject:operation];
    }
    [dataGate unlock];
}


- (void) temporarilySuspend:(NSTimeInterval) timeInterval {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resume) object:nil];
    [dataGate lock];
    {
        [queue setSuspended:YES];
    }
    [dataGate unlock];
    [self performSelector:@selector(resume) withObject:nil afterDelay:timeInterval];
}


- (void) temporarilySuspend {
    [self temporarilySuspend:1];
}


- (void) resume {
    [dataGate lock];
    {
        [queue setSuspended:NO];
    }
    [dataGate unlock];
}


- (BOOL) hasPriorityOperations {
    BOOL result;
    [dataGate lock];
    {
        result = (priorityOperationsCount > 0);
    }
    [dataGate unlock];
    return result;
}


- (void) notifyOperationDestroyed:(Operation*) operation
                     withPriority:(QueuePriority) priority {
    [dataGate lock];
    {
        if (priority >= Priority) {
            priorityOperationsCount--;
        }
        
        //[operations removeObject:operation];
    }
    [dataGate unlock];
}


@end