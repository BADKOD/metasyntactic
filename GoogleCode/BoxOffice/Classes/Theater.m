//
//  Theater.m
//  BoxOfficeApplication
//
//  Created by Cyrus Najmabadi on 4/27/08.
//  Copyright 2008 Metasyntactic. All rights reserved.
//

#import "Theater.h"
#import "Performance.h"

@implementation Theater

@synthesize identifier;
@synthesize name;
@synthesize address;
@synthesize phoneNumber;
@synthesize sellsTickets;
@synthesize sourcePostalCode;


- (void) dealloc {
    self.identifier = nil;
    self.name = nil;
    self.address = nil;
    self.phoneNumber = nil;
    self.sellsTickets = nil;
    self.sourcePostalCode = nil;
    [movieToShowtimesMap release];
    
    [super dealloc];
}

+ (NSDictionary*) decodeShowtimeMap:(NSDictionary*) map {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    for (NSString* key in map) {
        NSArray* performances = [map objectForKey:key];
        NSMutableArray* decodedPerformances = [NSMutableArray array];
        
        for (NSDictionary* performance in performances) {
            [decodedPerformances addObject:[Performance performanceWithDictionary:performance]];
        }
        
        [dictionary setObject:decodedPerformances forKey:key];
    }
    
    return dictionary;
}

+ (NSDictionary*) encodeShowtimeMap:(NSDictionary*) map {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    for (NSString* key in map) {
        NSArray* performances = [map objectForKey:key];
        NSMutableArray* encodedPerformances = [NSMutableArray array];
        
        for (Performance* performance in performances) {
            [encodedPerformances addObject:[performance dictionary]];
        }
        
        [dictionary setObject:encodedPerformances forKey:key];
    }
    
    return dictionary;
}

+ (Theater*) theaterWithDictionary:(NSDictionary*) dictionary {
    return [Theater theaterWithIdentifier:[dictionary objectForKey:@"identifier"]
                                     name:[dictionary objectForKey:@"name"]
                                  address:[dictionary objectForKey:@"address"]
                              phoneNumber:[dictionary objectForKey:@"phoneNumber"]
                             sellsTickets:[dictionary objectForKey:@"sellsTickets"]
                      movieToShowtimesMap:[dictionary objectForKey:@"movieToShowtimesMap"]  //[Theater decodeShowtimeMap:[dictionary objectForKey:@"movieToShowtimeMap"]]
                         sourcePostalCode:[dictionary objectForKey:@"sourcePostalCode"]];
}

NSComparisonResult compareDateStrings(id t1, id t2, void* context) {
    NSString* s1 = t1;
    NSString* s2 = t2;
    
    NSDate* d1 = [NSDate dateWithNaturalLanguageString:s1];
    NSDate* d2 = [NSDate dateWithNaturalLanguageString:s2];
    
    return [d1 compare:d2];
}

- (id)         initWithIdentifier:(NSString*) identifier_
                             name:(NSString*) name_
                          address:(NSString*) address_
                      phoneNumber:(NSString*) phoneNumber_
                     sellsTickets:(NSString*) sellsTickets_
              movieToShowtimesMap:(NSDictionary*) movieToShowtimesMap_
                    sourcePostalCode:(NSString*) sourcePostalCode_ {
    if (self = [self init]) {
        self.identifier = identifier_;
        self.name = [name_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.address = [address_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.phoneNumber = phoneNumber_ != nil ? phoneNumber_ : @"";
        self.sellsTickets = sellsTickets_;
        self.sourcePostalCode = sourcePostalCode_;
        movieToShowtimesMap = [movieToShowtimesMap_ retain];
    }
    
    return self;
}

+ (Theater*) theaterWithIdentifier:(NSString*) identifier
                              name:(NSString*) name
                           address:(NSString*) address
                       phoneNumber:(NSString*) phoneNumber
                      sellsTickets:(NSString*) sellsTickets
               movieToShowtimesMap:(NSDictionary*) map
                     sourcePostalCode:(NSString*) sourcePostalCode {
    return [[[Theater alloc] initWithIdentifier:identifier
                                           name:name
                                        address:address
                                    phoneNumber:phoneNumber
                                   sellsTickets:sellsTickets
                            movieToShowtimesMap:map
                                  sourcePostalCode:sourcePostalCode] autorelease];
}

- (NSDictionary*) dictionary {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:identifier forKey:@"identifier"];
    [dictionary setObject:name forKey:@"name"];
    [dictionary setObject:address forKey:@"address"];
    [dictionary setObject:phoneNumber forKey:@"phoneNumber"];
    [dictionary setObject:sellsTickets forKey:@"sellsTickets"];
    [dictionary setObject:movieToShowtimesMap forKey:@"movieToShowtimesMap"]; //[Theater encodeShowtimeMap:self.movieToShowtimesMap] forKey:@"movieToShowtimeMap"];
    [dictionary setObject:sourcePostalCode forKey:@"sourcePostalCode"];
    return dictionary;
}

- (NSString*) description {
    return [[self dictionary] description];
}

- (BOOL) isEqual:(id) anObject {
    Theater* other = anObject;
    return
        [self.identifier isEqual:other.identifier] &&
        [self.name isEqual:other.name];
}

- (NSUInteger) hash {
    return
        [self.identifier hash] +
        [self.name hash];
}

+ (NSString*) processShowtime:(NSString*) showtime {
    if ([showtime hasSuffix:@" PM"]) {
        return [NSString stringWithFormat:@"%@pm", [showtime substringToIndex:[showtime length] - 3]];
    } else if ([showtime hasSuffix:@" AM"]) {
        return [NSString stringWithFormat:@"%@am", [showtime substringToIndex:[showtime length] - 3]];        
    }
    
    return showtime;
}

- (NSArray*) movieTitles {
    return [movieToShowtimesMap allKeys];
}

- (NSArray*) performances:(Movie*) movie {
    NSArray* encodedArray = [movieToShowtimesMap objectForKey:movie.identifier];
    if (encodedArray == nil) {
        return [NSArray array];
    }
    
    NSMutableArray* decodedArray = [NSMutableArray array];
    for (NSDictionary* dict in encodedArray) {
        [decodedArray addObject:[Performance performanceWithDictionary:dict]];
    }
    
    return decodedArray;
}

@end
