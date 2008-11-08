package org.metasyntactic;

import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.*;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import org.metasyntactic.caches.scores.ScoreType;
import org.metasyntactic.data.Movie;
import org.metasyntactic.data.Score;
import org.metasyntactic.utilities.MovieViewUtilities;
import org.metasyntactic.views.NowPlayingPreferenceDialog;

import java.util.ArrayList;
import java.util.List;

/** @author mjoshi@google.com (Megha Joshi) */
public class AllMoviesActivity_old extends ListActivity {
  private NowPlayingActivity activity;
  private List<Movie> movies = new ArrayList<Movie>();
  private static MoviesAdapter mAdapter;
  private static Context mContext;

  public static final int MENU_SORT = 1;
  public static final int MENU_SETTINGS = 2;


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    // TODO Auto-generated method stub
    super.onCreate(savedInstanceState);
    activity = (NowPlayingActivity) getParent();
    mContext = this;

    // Set up Movies adapter
    mAdapter = new MoviesAdapter(this);
    setListAdapter(mAdapter);
  }


  @Override
  public boolean onCreateOptionsMenu(Menu menu) {

    menu.add(0, MENU_SORT, 0, R.string.menu_movie_sort).setIcon(
        android.R.drawable.star_on);

    menu.add(0, MENU_SETTINGS, 0, R.string.settings).setIcon(
        android.R.drawable.ic_menu_preferences).setIntent(
        new Intent(this, SettingsActivity.class))
        .setAlphabeticShortcut('s');

    return super.onCreateOptionsMenu(menu);
  }


  public INowPlaying getNowPlayingActivityContext() {
    return activity;
  }


  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == MENU_SORT) {
      NowPlayingPreferenceDialog builder =
          new NowPlayingPreferenceDialog(this.activity)

              .setTitle(R.string.movies_select_sort_title).setKey(
              NowPlayingPreferenceDialog.Preference_keys.MOVIES_SORT)
              .setEntries(R.array.entries_movies_sort_preference).show();

      return true;
    }
    return false;
  }


  class MoviesAdapter extends BaseAdapter {
    private final Context mContext;

    private final LayoutInflater mInflater;


    public MoviesAdapter(Context context) {
      mContext = context;
      // Cache the LayoutInflate to avoid asking for a new one each time.
      mInflater = LayoutInflater.from(context);

    }


    public Object getItem(int i) {
      return i;
    }


    public long getItemId(int i) {
      return i;
    }


    public View getView(int position, View convertView, ViewGroup viewGroup) {
      NowPlayingControllerWrapper mController = activity.getController();

      MovieViewHolder holder;

      convertView = mInflater.inflate(R.layout.movieview, null);

      holder = new MovieViewHolder();
      holder.toggleButton = (Button) convertView.findViewById(R.id.togglebtn);

      holder.score = (Button) convertView.findViewById(R.id.score);
      holder.divider = (ImageView) convertView.findViewById(R.id.divider1);
      holder.title = (TextView) convertView.findViewById(R.id.title);
      holder.rating = (TextView) convertView.findViewById(R.id.rating);
      holder.length = (TextView) convertView.findViewById(R.id.length);
      holder.header = (TextView) convertView.findViewById(R.id.header);
      convertView.setTag(holder);

      Resources res = mContext.getResources();
      final Movie movie = movies.get(position);

      String headerText =
          MovieViewUtilities.getHeader(movies, position, mController
              .getAllMoviesSelectedSortIndex());
      if (headerText != null) {
        holder.header.setVisibility(1);
        holder.header.setText(headerText);
      } else {
        holder.header.setVisibility(-1);
        holder.header.setHeight(0);
        holder.divider.setVisibility(-1);
        holder.divider.setMaxHeight(0);
      }

      holder.title.setText(movie.getDisplayTitle());
      holder.rating.setText(MovieViewUtilities.formatRatings(movie
          .getRating(), res));
      holder.length.setText(MovieViewUtilities.formatLength(movie
          .getLength(), res));
      holder.toggleButton.setOnClickListener(new Button.OnClickListener() {

        public void onClick(View v) {
          Intent intent = new Intent();
          intent.setClass(mContext, MovieDetailsActivity.class);
          intent.putExtra("movie", (Parcelable) movie);

          startActivity(intent);
        }

      });

      // Get and set scores text and background image
      Score score = mController.getScore(movie);
      int scoreValue = -1;
      if (score != null && !score.getValue().equals("")) {
        scoreValue = Integer.parseInt(score.getValue());

      } else {

      }
      ScoreType scoreType = mController.getScoreType();

      holder.score.setBackgroundDrawable(MovieViewUtilities
          .formatScoreDrawable(scoreValue, scoreType, res));
      if (scoreValue != -1) {
        holder.score.setText(String.valueOf(scoreValue));
      }
      return convertView;
    }


    class MovieViewHolder {
      TextView header;
      Button score;
      TextView title;
      TextView rating;
      TextView length;
      Button toggleButton;
      ImageView divider;
    }


    public int getCount() {
      return movies.size();
    }


    public void refreshMovies(List<Movie> new_movies) {
      movies = new_movies;
      notifyDataSetChanged();
    }
  }


  public static void refresh(List<Movie> movies) {

    mAdapter.refreshMovies(movies);
  }
}
