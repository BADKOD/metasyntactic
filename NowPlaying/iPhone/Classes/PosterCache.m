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

#import "PosterCache.h"

#import "AppDelegate.h"
#import "ApplePosterDownloader.h"
#import "Application.h"
#import "FandangoPosterDownloader.h"
#import "FileUtilities.h"
#import "ImageUtilities.h"
#import "ImdbPosterDownloader.h"
#import "InternationalDataCache.h"
#import "LargePosterCache.h"
#import "Model.h"
#import "Movie.h"
#import "NetworkUtilities.h"

@interface PosterCache()
@end


@implementation PosterCache

- (void) dealloc {
    [super dealloc];
}


+ (PosterCache*) cache {
    return [[[PosterCache alloc] init] autorelease];
}


- (Model*) model {
    return [Model model];
}


- (NSString*) posterFilePath:(Movie*) movie {
    NSString* sanitizedTitle = [FileUtilities sanitizeFileName:movie.canonicalTitle];
    return [[[Application moviesPostersDirectory] stringByAppendingPathComponent:sanitizedTitle] stringByAppendingPathExtension:@"jpg"];
}


- (NSString*) smallPosterFilePath:(Movie*) movie {
    NSString* sanitizedTitle = [FileUtilities sanitizeFileName:movie.canonicalTitle];
    return [[[Application moviesPostersDirectory] stringByAppendingPathComponent:sanitizedTitle] stringByAppendingString:@"-small.png"];
}


- (NSData*) downloadPosterWorker:(Movie*) movie {
    NSData* data = [NetworkUtilities dataWithContentsOfAddress:movie.poster];
    if (data != nil) {
        return data;
    }

    Movie* internationalMovie = [self.model.internationalDataCache findInternationalMovie:movie];
    data = [NetworkUtilities dataWithContentsOfAddress:internationalMovie.poster];
    if (data != nil) {
        return data;
    }

    data = [ApplePosterDownloader download:movie];
    if (data != nil) {
        return data;
    }

    data = [FandangoPosterDownloader download:movie];
    if (data != nil) {
        return data;
    }

    data = [ImdbPosterDownloader download:movie];
    if (data != nil) {
        return data;
    }

    [self.model.largePosterCache downloadFirstPosterForMovie:movie];

    // if we had a network connection, then it means we don't know of any
    // posters for this movie.  record that fact and try again another time
    if ([NetworkUtilities isNetworkAvailable]) {
        return [NSData data];
    }

    return nil;
}


- (void) updateMovieDetails:(Movie*) movie force:force {
    NSString* path = [self posterFilePath:movie];

    NSDate* modificationDate = [FileUtilities modificationDate:path];
    if (modificationDate != nil) {
        if ([FileUtilities size:path] > 0) {
            // already have a real poster.
            return;
        }

        if (!force) {
            // sentinel value.  only update if it's been long enough.
            if (ABS(modificationDate.timeIntervalSinceNow) < THREE_DAYS) {
                return;
            }
        }
    }

    NSData* data = [self downloadPosterWorker:movie];
    if (data != nil) {
        [FileUtilities writeData:data toFile:path];

        if (data.length > 0) {
            [AppDelegate minorRefresh];
        }
    }
}


- (UIImage*) posterForMovie:(Movie*) movie {
    NSString* path = [self posterFilePath:movie];
    NSData* data = [FileUtilities readData:path];
    return [UIImage imageWithData:data];
}


- (UIImage*) smallPosterForMovie:(Movie*) movie {
    NSString* smallPosterPath = [self smallPosterFilePath:movie];
    NSData* smallPosterData;

    if ([FileUtilities size:smallPosterPath] == 0) {
        NSData* normalPosterData = [FileUtilities readData:[self posterFilePath:movie]];
        smallPosterData = [ImageUtilities scaleImageData:normalPosterData
                                                toHeight:SMALL_POSTER_HEIGHT];

        [FileUtilities writeData:smallPosterData toFile:smallPosterPath];
    } else {
        smallPosterData = [FileUtilities readData:smallPosterPath];
    }

    return [UIImage imageWithData:smallPosterData];
}

@end