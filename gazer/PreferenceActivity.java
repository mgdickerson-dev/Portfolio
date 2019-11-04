package com.example.gazer;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class PreferenceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_preference);
        PreferenceFragment frag = new PreferenceFragment();
        getFragmentManager().beginTransaction()
                .replace(R.id.fragment2, frag, null)
                .commit();
    }
}
