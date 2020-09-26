package io.dcloud.H52FE1175;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.widget.Toast;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        runInt(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        runInt(intent);
    }

    public static String printKeyHash(Activity context) {
        PackageInfo packageInfo;
        String key = null;
        try {
            //getting application package name, as defined in manifest
            String packageName = context.getApplicationContext().getPackageName();

            //Retriving package info
            packageInfo = context.getPackageManager().getPackageInfo(packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES);

            Log.e("Package Name=", context.getApplicationContext().getPackageName());

            for (Signature signature : packageInfo.signingInfo.getApkContentsSigners()) {
                MessageDigest md = MessageDigest.getInstance("SHA");
                md.update(signature.toByteArray());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
                    key = new String(Base64.encode(md.digest(), 0));
                    Log.e("Key Hash=", key);
                }

                // String key = new String(Base64.encodeBytes(md.digest()));
            }
        } catch (PackageManager.NameNotFoundException e1) {
            Log.e("Name not found", e1.toString());
        }
        catch (NoSuchAlgorithmException e) {
            Log.e("No such an algorithm", e.toString());
        } catch (Exception e) {
            Log.e("Exception", e.toString());
        }

        return key;
    }

    MethodChannel channel;

    String url;


    void toast(String string){
        Toast.makeText(this,string,Toast.LENGTH_LONG).show();
    }

    private void runInt(Intent intent) {
        if( channel == null ){
            channel = new MethodChannel(getFlutterView(), "app.channel.shared.data");

            channel.setMethodCallHandler(
                    (call, result) -> {
                        if (call.method.equals("toast")) {
                            toast(call.arguments.toString());
                        } else if(call.method.equals("deep-link")){
                            result.success(url);
                            url = null;
                        } else if(call.method.equals("get-hash")){
                            result.success(printKeyHash(this));
                        }
                    });
        }
        if(intent.getData() != null) {
            //val action = intent.action

            url = intent.getData().toString();
            toast(url);
        }
    }


}
