package com.example.gazer;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if(savedInstanceState == null) {
            MainFragment frag = MainFragment.newInstance();
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment, frag, null)
                    .commit();
        }
    }

}
