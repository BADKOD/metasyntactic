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

@interface AbstractNavigationController : UINavigationController {
    ApplicationTabBarController* tabBarController;
    SearchViewController* searchViewController;
    BOOL viewLoaded;
    BOOL showingSearch;
}

@property (assign) ApplicationTabBarController* tabBarController;
@property (retain) SearchViewController* searchViewController;

- (id) initWithTabBarController:(ApplicationTabBarController*) tabBarController;

- (void) refresh;

- (NowPlayingModel*) model;
- (NowPlayingController*) controller;

- (void) pushTicketsView:(Movie*) movie
                 theater:(Theater*) theater
                   title:(NSString*) title
                animated:(BOOL) animated;

- (void) pushTheaterDetails:(Theater*) theater animated:(BOOL) animated;
- (void) pushMovieDetails:(Movie*) movie animated:(BOOL) animated;
- (void) pushReviewsView:(Movie*) movie animated:(BOOL) animated;

- (void) navigateToLastViewedPage;

- (void) showSearchView;
- (void) hideSearchView;

// @protected
- (Movie*) movieForTitle:(NSString*) canonicalTitle;

@end