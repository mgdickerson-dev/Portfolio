package com.example.gazer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.EditTextPreference;
import android.preference.PreferenceManager;
import androidx.annotation.Nullable;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;

public class PreferenceFragment extends android.preference.PreferenceFragment {
    //variable
    private Context mContext;
    //set up and add preferences
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        addPreferencesFromResource(R.xml.preferences);
        mContext = getActivity().getApplicationContext();
    }
    //handle user preferences
    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        EditTextPreference fontEditTextPreference = (EditTextPreference)findPreference("PREF_FONT");
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        fontEditTextPreference.setText(preferences.getString("PREF_FONT", "14"));
    }
    //create options menu
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
        inflater.inflate(R.menu.menu_preferences, menu);

    }
    //handle save button
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        //save and send preferences to main activity
        if (item.getItemId() == R.id.save){
            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
            String fontString = preferences.getString("PREF_FONT", "14");
            assert fontString != null;
            int font = Integer.parseInt(fontString);
            boolean bold = preferences.getBoolean("PREF_BOLD", false);

            if (font <= 70 && font >= 14) {
                Intent intent = new Intent();
                intent.putExtra("PREF_FONT", fontString);
                intent.putExtra("PREF_BOLD", bold);
                getActivity().setResult(Activity.RESULT_OK, intent);
                getActivity().finish();
            }
            else if (font > 70){
                Toast.makeText(mContext, getResources().getString(R.string.tooBig), Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(mContext, getResources().getString(R.string.tooSmall), Toast.LENGTH_SHORT).show();
            }
        }
        return true;
    }
}
