package com.example.gazer;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;

class PermissionUtil {
    //get permissions to be requested
    private static String[] getPermissions(){
        return new String[]{Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE};
    }
    //validate if permissions are granted
    private static boolean isPermissionsGranted(Context context, String permission){
        return ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED;
    }
    //validate all permissions have been granted
    static boolean allPermissionsGranted(Context mContext){
        for (String permission: getPermissions()){
            if (isPermissionsGranted(mContext, permission)){
                return false;
            }
        }
        return true;
    }
    //get permissions from user
    static void getRuntimePermission(Context mContext, Activity mActivity){
        List<String> permissions = new ArrayList<>();
        for (String permission: getPermissions()){
            if (isPermissionsGranted(mContext, permission)){
                permissions.add(permission);
            }
        }
        if (!permissions.isEmpty()){
            ActivityCompat.requestPermissions(mActivity, permissions.toArray(new String[0]), 1);
        }
    }

}
