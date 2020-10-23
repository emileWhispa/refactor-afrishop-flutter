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
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
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

    public void logAddToCartEvent (String contentData, String contentId, String contentType, String currency, double price) {
        AppEventsLogger logger = AppEventsLogger.newLogger(this);
        Bundle params = new Bundle();
        String event ="Add to cart";
        params.putString("fb_content", contentData);
        params.putString("fb_content_id", contentId);
        params.putString("fb_content_type", contentType);
        params.putString("fb_currency", currency);
        logger.logEvent("fb_mobile_add_to_cart", price, params);
    }

public void logSubmitApplicationEvent () {
    AppEventsLogger logger = AppEventsLogger.newLogger(this);
    // logger.logEvent(AppEventsConstants::FBSDKAppEventNameSubmitApplication);
}

public void logSearchEvent (String contentType, String contentData, String contentId, String searchString, Boolean success) {
    AppEventsLogger logger = AppEventsLogger.newLogger(this);
    Bundle params = new Bundle();
    params.putString("fb_content_type", contentType);
    params.putString("fb_content", contentData);
    params.putString("fb_content_id", contentId);
    params.putString( "fb_search_string", searchString);
    params.putInt("fb_success", success ? 1 : 0);
    logger.logEvent("fb_mobile_search", params);
}

/**
 * This function assumes logger is an instance of AppEventsLogger and has been
 * created using AppEventsLogger.newLogger() call.
 */
public void logInitiateCheckoutEvent (String contentData, String contentId, String contentType, int numItems, boolean paymentInfoAvailable, String currency, double totalPrice) {
    AppEventsLogger logger = AppEventsLogger.newLogger(this);
    Bundle params = new Bundle();
    params.putString("fb_content", contentData);
    params.putString("fb_content_id", contentId);
    params.putString("fb_content_type", contentType);
    params.putInt("fb_num_items", numItems);
    params.putInt("fb_payment_info_available", paymentInfoAvailable ? 1 : 0);
    params.putString("fb_currency", currency);
    logger.logEvent("fb_mobile_initiated_checkout", totalPrice, params);
}

public void logPurchase (double purchaseAmount,String currency) {
    AppEventsLogger logger = AppEventsLogger.newLogger(this);
    Bundle params = new Bundle();
    params.putString("fb_currency", currency);
    logger.logEvent( "fb_mobile_purchase", purchaseAmount, params);
}

public void logSignupEvent (String email) {
    AppEventsLogger logger = AppEventsLogger.newLogger(this);
    Bundle params = new Bundle();
    params.putString("email", email);
    logger.logEvent("signup", params);
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
                        else if(call.method.equals("logAddToCartEvent")){
                            
                            String contentData = call.argument("contentData"); // .argument returns the correct type
                            String contentId = call.argument("contentId"); 
                            String contentType = call.argument("contentType");
                            String currency =  call.argument("currency");
                            double price = call.argument("price");
                            // for the assignment
                            logAddToCartEvent(contentData,contentId,contentType,currency,price);
                        }
                        else if(call.method.equals("signup")){
                            logSubmitApplicationEvent();
                        }
                        else if(call.method.equals("logSearchEvent")){
                            String contentData = call.argument("contentData"); // .argument returns the correct type
                            String contentId = call.argument("contentId"); 
                            String contentType = call.argument("contentType");
                            String searchString =  call.argument("searchString");
                            Boolean success = call.argument("success");
                            logSearchEvent(contentType,contentData,contentId,searchString,success);  
                        }
                        else if(call.method.equals("logInitiateCheckoutEvent")){
                           String contentData =  call.argument("contentData");
                           String contentId =  call.argument("contentId");
                           String contentType = call.argument("contentType");
                           Integer numItems = call.argument("numItems");
                           Boolean paymentInfoAvailable = call.argument("paymentInfoAvailable");
                           String currency =  call.argument("currency");
                           double totalPrice =  call.argument("totalPrice");
                           
                            logInitiateCheckoutEvent (contentData,  contentId,  contentType,  numItems,  paymentInfoAvailable,  currency,  totalPrice);
                        }
                        else if(call.method.equals("logPurchase")){
                            String currency =  call.argument("currency");
                            double purchaseAmount =  call.argument("purchaseAmount");
                            logPurchase(purchaseAmount,currency);
                        }
                        else if(call.method.equals("logSignupEvent")){
                            String email = call.argument("email");
                            logSignupEvent(email);
                        }
                    
                    });
        }
        if(intent.getData() != null) {
            //val action = intent.action

            url = intent.getData().toString();
            toast(url);
        }
    }

    /**
 * This function assumes logger is an instance of AppEventsLogger and has been
 * created using AppEventsLogger.newLogger() call.
 */


}
