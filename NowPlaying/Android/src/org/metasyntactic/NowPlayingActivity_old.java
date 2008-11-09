// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package org.metasyntactic;

import android.app.TabActivity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.widget.TabHost;

import org.metasyntactic.data.Movie;

import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;


public class NowPlayingActivity_old extends TabActivity implements INowPlaying {

    // This global instance is used in NowPlayingModel, MovieDetailsActivity.
    public static NowPlayingActivity_old instance;

    private TabHost mTabHost;
    NowPlayingControllerWrapper controller;
    private final BroadcastReceiver broadcastReceiver =
        new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                refresh();

            }
        };
    
        /** Updates display of the list of movies. */
        public void refresh() {
            List<Movie> movies = controller.getMovies();
            Comparator comparator =
                MOVIE_ORDER[controller.getAllMoviesSelectedSortIndex()];
            Collections.sort(movies, comparator);
            AllMoviesActivity.refresh(movies);
        
        }

    private final ServiceConnection serviceConnection =
        new ServiceConnection() {
            public void onServiceConnected(ComponentName className,
                            IBinder service) {
                // This is called when the connection with the service has been
                // established, giving us the service object we can use to
                // interact with the service. We are communicating with our
                // service through an IDL interface, so get a client-side
                // representation of that from the raw service object.
                controller =
                    new NowPlayingControllerWrapper(INowPlayingController.Stub
                        .asInterface(service));
                onControllerConnected();
            }


            public void onServiceDisconnected(ComponentName className) {
                controller = null;
            }
        };


    private void onControllerConnected() {
        int selectedTab = controller.getSelectedTabIndex();
        getTabHost().setCurrentTab(selectedTab);
        refresh();
    }


    public NowPlayingActivity_old() {
        instance = this;
    }
   
    public Context getContext() {
        return this;
    }


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        boolean bindResult =
            bindService(new Intent(getBaseContext(),
                NowPlayingControllerService.class), serviceConnection,
                Context.BIND_AUTO_CREATE);

        if (!bindResult) {
            throw new RuntimeException("Failed to bind to service!");
        }
        setContentView(R.layout.tabs);
        mTabHost = getTabHost();
        
          setUpMoviesTab(mTabHost);
        setUpTheatersTab(mTabHost);
        setUpUpcomingTab(mTabHost);

        mTabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            public void onTabChanged(String s) {
                int currentTab = getTabHost().getCurrentTab();
                controller.setSelectedTabIndex(currentTab);
            }
        });
    }


    private void setUpUpcomingTab(final TabHost tabs) {
        tabs.addTab(tabs.newTabSpec("upcoming_tab").setIndicator(
            getResources().getString(R.string.upcomingIconLabel),
            getResources().getDrawable(R.drawable.upcoming)).setContent(
                new Intent(this, AllTheatersActivity.class)));
    }
   

    private void setUpTheatersTab(final TabHost tabs) {
        tabs.addTab(tabs.newTabSpec("theaters_tab").setIndicator(
            getResources().getString(R.string.theatersIconLabel),
            getResources().getDrawable(R.drawable.theatres)).setContent(
            new Intent(this, AllTheatersActivity.class)));
    }


    private void setUpMoviesTab(final TabHost tabs) {
        tabs.addTab(tabs.newTabSpec("movies_tab").setIndicator(
            getResources().getString(R.string.moviesIconLabel),
            getResources().getDrawable(R.drawable.movies)).setContent(
            new Intent(this, AllMoviesActivity.class)));
    }


    /**
     * Returns an instance of NowPlayingControllerWrapper associated with this
     * Activity.
     * 
     * @return controller instance of NowPlayingControllerWrapper
     */
    public NowPlayingControllerWrapper getController() {
        return controller;
    }


    @Override
    protected void onDestroy() {
        unbindService(serviceConnection);
        super.onDestroy();
    }


    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(broadcastReceiver, new IntentFilter(
            Application.NOW_PLAYING_CHANGED_INTENT));
    }


    @Override
    protected void onPause() {
        unregisterReceiver(broadcastReceiver);
        super.onPause();
    }
    

    final Comparator<Movie> TITLE_ORDER = new Comparator<Movie>() {
                public int compare(Movie m1, Movie m2) {
                    return m1.getDisplayTitle().compareTo(m2.getDisplayTitle());
                }
            };
            
            final Comparator<Movie> RELEASE_ORDER = new Comparator<Movie>() {
                public int compare(Movie m1, Movie m2) {
                    Date d1;
                    Date d2;
                    if (m1.getReleaseDate() == null) {
                        Calendar c1 = Calendar.getInstance();
                        c1.set(1900, 11, 11);
                        d1 = c1.getTime();
                    } else
                        d1 = m1.getReleaseDate();
    
                    if (m2.getReleaseDate() == null) {
                        Calendar c2 = Calendar.getInstance();
                        c2.set(1900, 11, 11);
                        d2 = c2.getTime();
                    } else
                        d2 = m2.getReleaseDate();
                    return d2.compareTo(d1);
    
    
    
                }
            };
    final Comparator<Movie> SCORE_ORDER = new Comparator<Movie>() {
                public int compare(Movie m1, Movie m2) {
                    if (controller.getScore(m1) == null
                        && controller.getScore(m2) == null) {
                        return 0;
                    }
                    if (controller.getScore(m1) != null
                        && controller.getScore(m2) != null) {
                        return controller.getScore(m2).compareTo(
                            controller.getScore(m1));
                    }
    
                    // if m2 is null then m1 is greater
                    if (controller.getScore(m1) != null) {
                        return -1;
                    }
    
                    return 1;
                }
            };
    final Comparator[] MOVIE_ORDER = {TITLE_ORDER, RELEASE_ORDER, SCORE_ORDER};

   

}
