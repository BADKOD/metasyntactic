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

#import "AllMoviesViewController.h"

#import "BoxOfficeStockImages.h"
#import "Model.h"
#import "MovieTitleCell.h"

@interface AllMoviesViewController()
@end


@implementation AllMoviesViewController

- (NSArray*) movies {
  return [Model model].movies;
}


- (BOOL) sortingByTitle {
  return [Model model].allMoviesSortingByTitle;
}


- (BOOL) sortingByReleaseDate {
  return [Model model].allMoviesSortingByReleaseDate;
}


- (BOOL) sortingByScore {
  return [Model model].allMoviesSortingByScore;
}


- (BOOL) sortingByFavorite {
  return [Model model].allMoviesSortingByFavorite;
}


- (NSInteger(*)(id,id,void*)) sortByReleaseDateFunction {
  return compareMoviesByReleaseDateDescending;
}


- (UISegmentedControl*) createSegmentedControl {
  UISegmentedControl* control = [[[UISegmentedControl alloc] initWithItems:
                                  [NSArray arrayWithObjects:
                                   LocalizedString(@"Release", @"Must be very short. 1 word max. This is on a button that allows the user to sort movies based on how recently they were released."),
                                   LocalizedString(@"Title", @"Must be very short. 1 word max. This is on a button that allows the user to sort movies based on their title."),
                                   LocalizedString(@"Score", @"Must be very short. 1 word max. This is on a button that allows users to sort movies by how well they were rated."),
                                   [BoxOfficeStockImages whiteStar],
                                   nil]] autorelease];

  control.segmentedControlStyle = UISegmentedControlStyleBar;
  control.selectedSegmentIndex = [Model model].allMoviesSelectedSegmentIndex;

  [control addTarget:self
              action:@selector(onSortOrderChanged:)
    forControlEvents:UIControlEventValueChanged];

  CGRect rect = control.frame;
  rect.size.width = 310;
  control.frame = rect;

  return control;
}


- (void) onSortOrderChanged:(id) sender {
  [Model model].allMoviesSelectedSegmentIndex = segmentedControl.selectedSegmentIndex;
  [self majorRefresh];
}


- (id) init {
  if ((self = [super init])) {
    self.title = LocalizedString(@"Movies", nil);
  }

  return self;
}


- (void) loadView {
  [super loadView];
}


- (void) didReceiveMemoryWarningWorker {
  [super didReceiveMemoryWarningWorker];
}


- (UITableViewCell*) createCell:(Movie*) movie {
  return [MovieTitleCell movieTitleCellForMovie:movie inTableView:self.tableView];
}

@end
