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

#import "UpcomingMoviesViewController.h"

#import "NowPlayingModel.h"
#import "UpcomingCache.h"
#import "UpcomingMovieCell.h"
#import "UpcomingMoviesNavigationController.h"

@implementation UpcomingMoviesViewController

- (void) dealloc {
    [super dealloc];
}


- (NSArray*) movies {
    return self.model.upcomingCache.upcomingMovies;
}


- (BOOL) sortingByTitle {
    return self.model.upcomingMoviesSortingByTitle;
}


- (BOOL) sortingByReleaseDate {
    return self.model.upcomingMoviesSortingByReleaseDate;
}


- (BOOL) sortingByScore {
    return NO;
}


- (int(*)(id,id,void*)) sortByReleaseDateFunction {
    return compareMoviesByReleaseDateAscending;
}


- (void) setupSegmentedControl {
    self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:
                              [NSArray arrayWithObjects:
                               NSLocalizedString(@"Title", @"This is on a button that allows the user to sort movies based on their title."),
                               NSLocalizedString(@"Release", @"This is on a button that allows the user to sort movies based on how recently they were released"), nil]] autorelease];

    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = self.model.upcomingMoviesSelectedSegmentIndex;

    [segmentedControl addTarget:self
                         action:@selector(onSortOrderChanged:)
               forControlEvents:UIControlEventValueChanged];

    CGRect rect = segmentedControl.frame;
    rect.size.width = 240;
    segmentedControl.frame = rect;

    self.navigationItem.titleView = segmentedControl;
}


- (void) onSortOrderChanged:(id) sender {
    self.model.upcomingMoviesSelectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    [self refresh];
}


- (id) initWithNavigationController:(UpcomingMoviesNavigationController*) controller {
    if (self = [super initWithNavigationController:controller]) {
        self.title = NSLocalizedString(@"Upcoming", nil);
        self.tableView.rowHeight = 100;
    }

    return self;
}


- (id) createCell:(NSString*) reuseIdentifier {
    return [[[UpcomingMovieCell alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
                                     reuseIdentifier:reuseIdentifier
                                               model:self.model] autorelease];
}


- (void) refresh {
    self.tableView.rowHeight = 100;
    [super refresh];
}


@end