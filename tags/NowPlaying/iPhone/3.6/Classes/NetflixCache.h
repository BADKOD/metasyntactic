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

#import "AbstractNetflixCache.h"

@interface NetflixCache : AbstractNetflixCache {
@private
    // accessed from multiple threads.  needs lock
    NSArray* feedsData;
    NSDictionary* queuesData;
    NSDate* lastQuotaErrorDate;
}

@property (readonly, retain) NSDate* lastQuotaErrorDate;

+ (NSArray*) mostPopularTitles;

- (NSArray*) movieSearch:(NSString*) query error:(NSString**) error;
- (NSArray*) peopleSearch:(NSString*) query;

- (BOOL) isEnqueued:(Movie*) movie;
- (NSArray*) statusesForMovie:(Movie*) movie;

- (void) update;

- (NSArray*) feeds;
- (Queue*) queueForFeed:(Feed*) feed;
- (Feed*) feedForKey:(NSString*) key;
- (Queue*) queueForKey:(NSString*) key;
- (NSString*) titleForKey:(NSString*) key;
- (NSString*) titleForKey:(NSString*) key includeCount:(BOOL) includeCount;
- (NSArray*) moviesForRSSTitle:(NSString*) title;
- (NSInteger) movieCountForRSSTitle:(NSString*) title;

- (NSArray*) castForMovie:(Movie*) movie;
- (NSArray*) directorsForMovie:(Movie*) movie;
- (NSString*) synopsisForMovie:(Movie*) movie;
- (NSString*) netflixRatingForMovie:(Movie*) movie;
- (NSString*) userRatingForMovie:(Movie*) movie;
- (NSArray*) formatsForMovie:(Movie*) movie;
- (NSArray*) similarMoviesForMovie:(Movie*) movie;
- (NSString*) netflixAddressForMovie:(Movie*) movie;
- (NSString*) availabilityForMovie:(Movie*) movie;

- (NSString*) noInformationFound;

- (void) lookupNetflixMovieForLocalMovieBackgroundEntryPoint:(Movie*) movie;

- (Movie*) netflixMovieForMovie:(Movie*) movie;

- (void) saveQueue:(Queue*) queue;
- (Movie*) promoteDiscToSeries:(Movie*) disc;
- (NSString*) userRatingsFile:(Movie*) movie;
- (NSString*) downloadEtag:(Feed*) feed;

- (void) checkApiResult:(XmlElement*) result;
- (NSString*) extractErrorMessage:(XmlElement*) element;

+ (void) processMovieItemList:(XmlElement*) element
                       movies:(NSMutableArray*) movies
                        saved:(NSMutableArray*) saved;

@end