package com.example.gazer;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.graphics.Typeface;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.preference.PreferenceManager;
import android.speech.tts.TextToSpeech;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import android.util.Size;
import android.util.SparseIntArray;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.naturallanguage.FirebaseNaturalLanguage;
import com.google.firebase.ml.naturallanguage.languageid.FirebaseLanguageIdentification;
import com.google.firebase.ml.naturallanguage.languageid.IdentifiedLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslator;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslatorOptions;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.text.FirebaseVisionText;
import com.google.firebase.ml.vision.text.FirebaseVisionTextRecognizer;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

public class MainFragment extends Fragment implements View.OnClickListener {

    //variables
    private Context mContext;
    private Activity mActivity;
    private Button buttonRead;
    private TextToSpeech textToSpeak;
    private TextureView textureView;
    private String translation;
    private String  textLanguage = "en";
    private CameraDevice mCameraDevice;
    private CameraCaptureSession mCameraCaptureSession;
    private CaptureRequest.Builder mCaptureRequestBuilder;
    private Size imageDimensions;
    private final ViewGroup nullParent = null;
    private Handler mBackgroundHandler;
    private HandlerThread mBackgroundThread;
    private StorageReference storageRef;
    private double avgConfidence;
    private static int font;
    private static boolean bold;
    private String fileName;
    private static final SparseIntArray ORIENTATION = new SparseIntArray();
    //orientations
    static {
        ORIENTATION.append(Surface.ROTATION_0, 90);
        ORIENTATION.append(Surface.ROTATION_90, 0);
        ORIENTATION.append(Surface.ROTATION_180, 270);
        ORIENTATION.append(Surface.ROTATION_270, 180);
    }
    //create new instance
    @SuppressWarnings("WeakerAccess")
    public static MainFragment newInstance() { return new MainFragment(); }
    //set up
    @Override
    public void onCreate(@Nullable final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        createStorage();
        mContext = getContext();
        textToSpeak = new TextToSpeech(mContext, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {

                if (status != TextToSpeech.ERROR){
                    Locale locale = new Locale("en", "US");
                    textToSpeak.setLanguage(locale);
                }
            }
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mActivity = getActivity();
    }

    //set user preferences and views
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        textureView = view.findViewById(R.id.textureView);
        textureView.setSurfaceTextureListener(textureListener);
        buttonRead = view.findViewById(R.id.buttonRead);
        buttonRead.setOnClickListener(this);

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        if (preferences.contains("PREF_FONT")){
            String fontString = preferences.getString("PREF_FONT", "14");
            bold = preferences.getBoolean("PREF_BOLD", false);
            assert fontString != null;
            font = Integer.parseInt(fontString);
            buttonRead.setTextSize(font);
            if (bold) {
                buttonRead.setTypeface(null, Typeface.BOLD);
            }
            else {
                buttonRead.setTypeface(null, Typeface.NORMAL);
            }
        }
    }
    //create options menu
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
        inflater.inflate(R.menu.menu_main, menu);

    }
    //set options functionality
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        //if preferences clicked open preference activity
        if (item.getItemId() == R.id.preferences && getActivity() != null){
            Intent intent = new Intent(mContext, PreferenceActivity.class);
            startActivityForResult(intent, 1);
        }
        //if share clicked open send activity
        if (item.getItemId() == R.id.share && getActivity() != null) {
            if (translation != null) {
                Intent sendIntent = new Intent();
                sendIntent.setAction(Intent.ACTION_SEND);
                sendIntent.putExtra(Intent.EXTRA_TEXT, translation);
                sendIntent.setType("text/plain");
                startActivity(sendIntent);
            }
            //validate text to send
            else {
                showToast(mContext, getResources().getString(R.string.errorSend));
                textToSpeak.speak(getResources().getString(R.string.errorSend), TextToSpeech.QUEUE_FLUSH, null, null);
            }
        }
        return true;
    }
    //receive and update user preferences
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == 1) {
            if (resultCode == Activity.RESULT_OK && data.hasExtra("PREF_BOLD")) {
                String fontString = data.getStringExtra("PREF_FONT");
                    bold = data.getBooleanExtra("PREF_BOLD", false);
                    font = Integer.parseInt(fontString);
                    buttonRead.setTextSize(font);
                    if (bold) {
                        buttonRead.setTypeface(null, Typeface.BOLD);
                    }
                    else {
                        buttonRead.setTypeface(null, Typeface.NORMAL);
                    }
            }
        }
    }
    //create view
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_main, container, false);
    }
    //handle read button click to take picture
    @Override
    public void onClick(View v) {

        if (v.getId() == R.id.buttonRead){
            //validate internet
            if (isNetworkConnected()) {
                buttonRead.setClickable(false);
                takePicture();

            }
            else {
                showToast(mContext, getResources().getString(R.string.needsWifi));
            }

        }
    }
    //validate internet
    private boolean isNetworkConnected() {
        ConnectivityManager cm = (ConnectivityManager) mActivity.getSystemService(Context.CONNECTIVITY_SERVICE);

        return cm.getActiveNetworkInfo() != null;
    }
    //surface texture listener
    private final TextureView.SurfaceTextureListener textureListener = new TextureView.SurfaceTextureListener() {
        //if permissions accepted open camera
        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {

            PermissionUtil.getRuntimePermission(mContext, mActivity);
            if (PermissionUtil.allPermissionsGranted(mContext)) {
                try {
                    openCamera();
                } catch (CameraAccessException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            return false;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surface) {
        }
    };

    //camera state callback
    private final CameraDevice.StateCallback stateCallback = new CameraDevice.StateCallback() {
        //create camera preview
        @Override
        public void onOpened(@NonNull CameraDevice camera) {
        mCameraDevice = camera;
        try {
            createCameraPreview();
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }
        //close camera
        @Override
        public void onDisconnected(@NonNull CameraDevice camera) {
        mCameraDevice.close();
        }
        //close and null camera
        @Override
        public void onError(@NonNull CameraDevice camera, int error) {

        mCameraDevice.close();
        mCameraDevice = null;
        }
    };
    //check if permission denied
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {

        if (requestCode == 101){
            if (grantResults[0] == PackageManager.PERMISSION_DENIED){
                showToast(mContext, getResources().getString(R.string.denied));
            }
        }

    }
    //create the camera preview
    private void createCameraPreview() throws CameraAccessException{
        SurfaceTexture texture = textureView.getSurfaceTexture();
        texture.setDefaultBufferSize(imageDimensions.getWidth(), imageDimensions.getHeight());
        Surface surface = new Surface(texture);
        mCaptureRequestBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
        mCaptureRequestBuilder.addTarget(surface);
        mCameraDevice.createCaptureSession(Collections.singletonList(surface), new CameraCaptureSession.StateCallback() {
            //update preview
            @Override
            public void onConfigured(@NonNull CameraCaptureSession session) {
                if (mCameraDevice == null){
                    return;
                }
                mCameraCaptureSession = session;
                try {
                    updatePreview();
                } catch (CameraAccessException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession session) {
            }
        },null);
    }
    //handle camera preview
    private void updatePreview() throws CameraAccessException {

        if (mCameraDevice == null){
            return;
        }
        mCaptureRequestBuilder.set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
        mCameraCaptureSession.setRepeatingRequest(mCaptureRequestBuilder.build(), null, mBackgroundHandler);

    }
    //open the camera
    private void openCamera() throws CameraAccessException {
        CameraManager manager = (CameraManager)mActivity.getSystemService(Context.CAMERA_SERVICE);
        String cameraId = manager.getCameraIdList()[0];
        CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraId);
        StreamConfigurationMap map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);

        if (map!=null)
            imageDimensions = map.getOutputSizes(SurfaceTexture.class)[0];
        //verify permissions
        if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
        && ActivityCompat.checkSelfPermission(mContext, Manifest.permission.WRITE_EXTERNAL_STORAGE)!= PackageManager.PERMISSION_DENIED){

            PermissionUtil.getRuntimePermission(mContext, mActivity);
            return;
        }

        manager.openCamera(cameraId, stateCallback, null);
    }
    //take picture
    private void takePicture(){


        Bitmap textBmp = textureView.getBitmap();
        if (textBmp != null) {
            FirebaseVisionImage fbImage = FirebaseVisionImage.fromBitmap(textBmp);
            recognizeText(fbImage);
        }
    }
    //open camera on resume
    @Override
    public void onResume() {
        super.onResume();

        startBackgroundThread();
        if (textureView.isAvailable()){
            try {
                openCamera();
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
        }
        else {
            textureView.setSurfaceTextureListener(textureListener);
        }
    }
    //start the background thread
    private void startBackgroundThread() {
        mBackgroundThread = new HandlerThread("Camera Background");
        mBackgroundThread.start();
        mBackgroundHandler = new Handler(mBackgroundThread.getLooper());

    }
    //stop the background thread on pause
    @Override
    public void onPause() {
        super.onPause();

        try {
            stopBackgroundThread();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    //stop the background thread
    private void stopBackgroundThread() throws InterruptedException{
        mBackgroundThread.quitSafely();
        mBackgroundThread.join();
        mBackgroundThread = null;
        mBackgroundHandler = null;
    }
    //extract text from firebase vision image
    private void recognizeText(FirebaseVisionImage image) {

        final FirebaseVisionTextRecognizer detector = FirebaseVision.getInstance()
                .getOnDeviceTextRecognizer();

        Task<FirebaseVisionText> result = detector.processImage(image);

        result.addOnSuccessListener(new OnSuccessListener<FirebaseVisionText>() {
            //sort extracted text and recognize language
            @Override
            public void onSuccess(FirebaseVisionText firebaseVisionText) {

                List<FirebaseVisionText.TextBlock> blocks = firebaseVisionText.getTextBlocks();
                    List<FirebaseVisionText.TextBlock> sortedBlocks = new ArrayList<>();
                    int i = 0;
                    int a = 0;
                    //sort
                    while (a < blocks.size()) {
                        for (FirebaseVisionText.TextBlock block : blocks) {
                            if (block.getBoundingBox() != null ) {
                                if (block.getBoundingBox().top == i) {
                                    sortedBlocks.add(block);
                                    a++;
                                }
                            }
                        }
                        i++;
                    }
                    StringBuilder stringBuilder = new StringBuilder();
                    for (FirebaseVisionText.TextBlock block : sortedBlocks) {

                        stringBuilder.append(block.getText());
                        stringBuilder.append("\n");
                    }

                    buttonRead.setClickable(true);
                    recognizeLanguage(stringBuilder.toString());
                }
        });

        result.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                showToast(mContext, getString(R.string.couldNotVerify));
            }
        });
    }
    //recognize language of extracted text
    private void recognizeLanguage(final String text){
        FirebaseLanguageIdentification languageIdentifier =
                FirebaseNaturalLanguage.getInstance().getLanguageIdentification();
        languageIdentifier.identifyPossibleLanguages(text)
                .addOnSuccessListener(
                        new OnSuccessListener<List<IdentifiedLanguage>>() {
                            //determine if english and read or check if needs translation
                            @Override
                            public void onSuccess(List<IdentifiedLanguage> identifiedLanguages) {
                                textLanguage = identifiedLanguages.get(0).getLanguageCode();
                                if (!textLanguage.equals("en")) {
                                    avgConfidence = identifiedLanguages.get(0).getConfidence();
                                    translate(text);
                                }
                                else{
                                    translation = text;
                                    showAlert(translation);
                                    avgConfidence = identifiedLanguages.get(0).getConfidence();
                                    saveString();
                                    textToSpeak.speak(text, TextToSpeech.QUEUE_FLUSH, null, null);
                                }
                            }
                        })
                .addOnFailureListener(
                        new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception e) {
                                showToast(mContext, getString(R.string.couldNotVerify));
                            }
                        });
    }
    //translate extracted text
    private void translate(final String text){
        Integer langCode = FirebaseTranslateLanguage.languageForLanguageCode(textLanguage.substring(0,2));
        if (langCode != null){
            FirebaseTranslatorOptions options =
                    new FirebaseTranslatorOptions.Builder()
                            .setSourceLanguage(langCode)
                            .setTargetLanguage(FirebaseTranslateLanguage.EN)
                            .build();
        final FirebaseTranslator translator =
                FirebaseNaturalLanguage.getInstance().getTranslator(options);
        FirebaseModelDownloadConditions conditions = new FirebaseModelDownloadConditions.Builder()
                .requireWifi()
                .build();
        showToast(mContext, getResources().getString(R.string.downloading));
        translator.downloadModelIfNeeded(conditions)
                .addOnSuccessListener(
                        new OnSuccessListener<Void>() {
                            @Override
                            //attempt model download
                            public void onSuccess(Void v) {
                                translator.translate(text)
                                        .addOnSuccessListener(
                                                new OnSuccessListener<String>() {
                                                    //translate text
                                                    @Override
                                                    public void onSuccess(@NonNull String translatedText) {

                                                        showToast(mContext, getResources().getString(R.string.complete));
                                                        translation = translatedText;
                                                        saveString();
                                                        textToSpeak.speak(translation, TextToSpeech.QUEUE_FLUSH, null, null);
                                                        showAlert(translation);
                                                    }
                                                })
                                        .addOnFailureListener(
                                                new OnFailureListener() {
                                                    @Override
                                                    public void onFailure(@NonNull Exception e) {
                                                        showToast(mContext, getString(R.string.couldNotVerify));
                                                    }
                                                });
                            }


                        })
                .addOnFailureListener(
                        new OnFailureListener() {
                            //no internet
                            @Override
                            public void onFailure(@NonNull Exception e) {

                                showToast(mContext, getResources().getString(R.string.needsWifi));
                            }
                        });
    }}
    //show toast
    private static void showToast(Context context, String text) {
        Toast toast = Toast.makeText(context, text, Toast.LENGTH_LONG);
        LinearLayout toastLayout = (LinearLayout) toast.getView();
        TextView toastTV = (TextView) toastLayout.getChildAt(0);
        if (font > 0) {
            toastTV.setTextSize(font);
        }
        if (bold) {
            toastTV.setTypeface(null, Typeface.BOLD);
        }
        toast.show();
    }
    //create storage reference
    private void createStorage(){
        FirebaseStorage storage = FirebaseStorage.getInstance();
        storageRef = storage.getReferenceFromUrl("gs://gazer-b767d.appspot.com");
    }
    //save read string
    private void saveString(){
        String stringBuilder = "Translation:\n" +
                translation +
                "\nLanguage:\n" +
                textLanguage +
                "\nConfidence:\n" +
                avgConfidence;
        writeToFile(stringBuilder, mContext);
        Uri file = Uri.fromFile(new File(mActivity.getFilesDir().getPath()+ "/" + fileName));
        if (file.getLastPathSegment()!=null)
        storageRef = storageRef.child("Text/" + file.getLastPathSegment());
        UploadTask uploadTask = storageRef.putFile(file);
        uploadTask.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception exception) {
                // Handle unsuccessful uploads
            }
        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {

            }
        });
    }
    //write translation to file
    private void writeToFile(String data,Context context) {
        try {
            fileName = Calendar.getInstance().getTimeInMillis() + avgConfidence + ".txt";
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput(fileName, Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }
    //show alert
    private void showAlert(String msg){
        LayoutInflater inflater = LayoutInflater.from(mContext);
        //noinspection ConstantConditions
        View view = inflater.inflate(R.layout.alert_layout, nullParent);
        TextView textview = view.findViewById(R.id.textMsg);
        textview.setText(msg);
        if (font > 0) {
            textview.setTextSize(font);
        }
        if (bold) {
            textview.setTypeface(null, Typeface.BOLD);
        }
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(mContext);
        alertDialog.setView(view);
        alertDialog.setPositiveButton("OK", null);
        AlertDialog alert = alertDialog.create();
        alert.show();
    }
}

