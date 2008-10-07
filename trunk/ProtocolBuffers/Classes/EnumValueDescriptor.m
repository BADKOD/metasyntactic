// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.
// http://code.google.com/p/protobuf/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "EnumValueDescriptor.h"

#import "Descriptor.pb.h"
#import "DescriptorPool.h"

@interface PBEnumValueDescriptor ()
    @property (assign) PBFileDescriptor* file;
    @property (assign) PBEnumDescriptor* type;
    @property (retain) PBEnumValueDescriptorProto* proto;
    @property int32_t index;
    @property (copy) NSString* fullName;
@end


@implementation PBEnumValueDescriptor

@synthesize index;
@synthesize fullName;
@synthesize proto;
@synthesize file;
@synthesize type;

- (void) dealloc {
    self.index = 0;
    self.fullName = nil;
    self.proto = nil;
    self.file = nil;
    self.type = nil;

    [super dealloc];
}


- (id) initWithProto:(PBEnumValueDescriptorProto*) proto_
                file:(PBFileDescriptor*) file_
              parent:(PBEnumDescriptor*) parent_
               index:(int32_t) index_ {
    if (self = [super init]) {
        self.index = index_;
        self.proto = proto_;
        self.file = file_;
        self.type = parent_;
        
        self.fullName = [NSString stringWithFormat:@"%@.%@", parent_.fullName, proto.name];
        
        [file.pool addSymbol:self];
        [file.pool addEnumValueByNumber:self];
    }
    
    return self;
}


+ (PBEnumDescriptor*) descriptorWithProto:(PBEnumValueDescriptorProto*) proto
                                     file:(PBFileDescriptor*) file
                                   parent:(PBEnumDescriptor*) parent
                                    index:(int32_t) index {
    return [[[PBEnumDescriptor alloc] initWithProto:proto file:file parent:parent index:index] autorelease];
}



- (int32_t) number {
    @throw [NSException exceptionWithName:@"NYI" reason:@"" userInfo:nil];
}


- (id<PBMessage>) toProto {
    return proto;
}


- (NSString*) name {
    return proto.name;
}


@end
