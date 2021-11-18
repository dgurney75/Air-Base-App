//FIREBASE CORE CLASSES
import com.distriqt.extension.core.Core;
import com.distriqt.extension.firebase.Firebase;
import com.distriqt.extension.firebase.FirebaseOptions;

//FIREBASE ANALYTICS CLASSES
import com.distriqt.extension.firebase.analytics.FirebaseAnalytics;
import com.distriqt.extension.firebase.analytics.EventObject;
import com.distriqt.extension.firebase.analytics.Params;

//FIREBASE AUTH CLASSES
import com.distriqt.extension.firebase.Firebase;
import com.distriqt.extension.firebase.auth.OAuthProvider;
import com.distriqt.extension.firebase.auth.OAuthCredential;
import com.distriqt.extension.firebase.auth.AuthCredential;
import com.distriqt.extension.firebase.auth.EmailAuthProvider;
import com.distriqt.extension.firebase.auth.FacebookAuthCredential;
import com.distriqt.extension.firebase.auth.PhoneAuthCredential;
import com.distriqt.extension.firebase.auth.PhoneAuthProvider;
import com.distriqt.extension.firebase.auth.FacebookAuthProvider;
import com.distriqt.extension.firebase.auth.FirebaseAuth;
import com.distriqt.extension.firebase.auth.GoogleAuthProvider;
import com.distriqt.extension.firebase.auth.builders.UserProfileChangeRequestBuilder;
import com.distriqt.extension.firebase.auth.events.FirebaseAuthEvent;
import com.distriqt.extension.firebase.auth.events.FirebaseUserEvent;
import com.distriqt.extension.firebase.auth.user.FirebaseUser;
import com.distriqt.extension.firebase.auth.user.UserInfo;


//CORE FIREBASE VARS
var _idToken: String;
var credential: AuthCredential;
var userDirectory: String;
var email: String;
var password: String;
var socialPlatform: String;
var firstTimeUser: String;
var phoneNumber: String;
var phoneVerifyID: String;
var signUpType: String;
var smsCode: String;



//SET UP CORE FIREBASE AND APPROPRIATE AUTH PROVIDERS
function initFirebase(): void {
	try {
		trace("Firebase Supported: " + Firebase.isSupported);

		//FIREBASE CORE SUPPORT
		if (Firebase.isSupported) {
			trace("Firebase Version:   " + Firebase.service.version);

			var success: Boolean = Firebase.service.initialiseApp();


			trace("Firebase.service.initialiseApp() = " + success);
			if (!success) {
				trace("CHECK YOUR CONFIGURATION");
			}

		}

		//FIREBASE AUTH SUPPORT
		if (FirebaseAuth.isSupported) {
			trace("FirebaseAuth Version:   " + FirebaseAuth.service.version);
		}

		trace("Is User Signed In?: " + FirebaseAuth.service.isSignedIn());

		FirebaseAuth.service.addEventListener(FirebaseAuthEvent.AUTHSTATE_CHANGED, authState_changedHandler);

	} catch (e: Error) {
		trace("ERROR: " + e.message);
	}
}


function dispose(): void {
	try {
		FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.AUTHSTATE_CHANGED, authState_changedHandler);

		Firebase.service.dispose();
		FirebaseAuth.service.dispose();
	} catch (e: Error) {
		trace(e.message);
	}
}



function getOptions(): void {
	if (Firebase.isSupported) {
		var options: FirebaseOptions = Firebase.service.getOptions();
		if (options != null) {
			trace(options.toString());
		} else {
			trace("APPLICATION NOT CONFIGURED");
		}
	}
}


function authState_changedHandler(event: FirebaseAuthEvent): void {
	trace("auth state changed: " + FirebaseAuth.service.isSignedIn());
	if (FirebaseAuth.service.isSignedIn() == true) {
		getCurrentUser();
	}
}





//GET CURRENT USER
function getCurrentUser(): void {

	if (contentStatus == "signUp") {
		auth_panel.fullNameMC.defaultTXT.dispose();
		auth_panel.emailMC.emailTXT.dispose();
		auth_panel.passwordMC.passwordTXT.dispose();
	}
	
	if (contentStatus == "signIn") {
		auth_panel.emailMC.emailTXT.dispose();
		auth_panel.passwordMC.passwordTXT.dispose();
	}

	if (FirebaseAuth.isSupported) {
		var user: FirebaseUser = FirebaseAuth.service.getCurrentUser();
		if (user != null) {

			trace("identifier:  " + user.identifier);
			userDirectory = user.identifier;

			trace("displayName: " + user.displayName);

			email = user.email;
			trace("email:       " + user.email);

			for each(var info: UserInfo in user.providers) {
				trace("------------------");
				trace("\tprovider:    " + info.providerId);
				trace("\tidentifier:  " + info.identifier);
				trace("\tdisplayName: " + info.displayName);
				trace("\temail:       " + info.email);
				trace("\tphone:       " + info.phoneNumber);
			}

			//SIGN IN AND GOTO HOME SCREEN
			activityDialog.dismiss();
			gotoAndPlay("start", "main");

		} else {
			trace("Not signed in");
		}
	}
}




//SEND PASSWORD RESET
function sendPasswordResetEmail(): void {
	if (FirebaseAuth.isSupported) {
		trace("sendPasswordResetEmail()");
		FirebaseAuth.service.addEventListener(
			FirebaseAuthEvent.SEND_PASSWORD_RESET_EMAIL_COMPLETE,
			sendPasswordResetEmail_completeHandler);

		FirebaseAuth.service.sendPasswordResetEmail(email);
	}
}

function sendPasswordResetEmail_completeHandler(event: FirebaseAuthEvent): void {
	trace("sendPasswordResetEmail(): complete: " + event.success + "::" + event.message);

	FirebaseAuth.service.removeEventListener(
		FirebaseAuthEvent.SEND_PASSWORD_RESET_EMAIL_COMPLETE,
		sendPasswordResetEmail_completeHandler);

	if (event.success != true) {
		showMessage("Password Reset Link Sent", "A password reset link has been sent to the email you provided.");
		return;
	}

	showMessage("Password Reset Link Sent", "A password reset link has been sent to the email you provided.");
}






//SIGN OUT
function signOut(): void {
	if (FirebaseAuth.isSupported) {
		if (FirebaseAuth.service.isSignedIn()) {
			var success: Boolean = FirebaseAuth.service.signOut();
			trace("signOut()=" + success);
			
			if(socialPlatform == "google"){
				googleSignOut();
			}
		
		    if(socialPlatform == "facebook"){
				facebookSignOut();
			}
			
			gotoAndPlay("signOut", "login");
		} else {
			trace("Not signed out");
		}
	}
}





//FIREBASE EMAIL NEW ACCOUNT SIGN-UP
function createUserWithEmail(): void {
	if (FirebaseAuth.isSupported) {

		activityDialog.show();

		trace("createUserWithEmailAndPassword()");
		FirebaseAuth.service.addEventListener(
			FirebaseAuthEvent.CREATE_USER_WITH_EMAIL_COMPLETE,
			createUserWithEmailAndPassword_completeHandler);

		FirebaseAuth.service.createUserWithEmailAndPassword(email, password);
	}
}

function createUserWithEmailAndPassword_completeHandler(event: FirebaseAuthEvent): void {
	trace("createUserWithEmailAndPassword(): complete: " + event.success + "::" + event.message);

	activityDialog.dismiss();

	firstTimeUser = "yes";
	contentStatus = "enrollment";
	closeAuthPanel();

	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.CREATE_USER_WITH_EMAIL_COMPLETE, createUserWithEmailAndPassword_completeHandler);

}






//FIREBASE EMAIL AUTH
function signInWithEmail(): void {
	if (FirebaseAuth.isSupported) {

		activityDialog.show();

		if (!FirebaseAuth.service.isSignedIn()) {
			trace("signInWithEmailAndPassword()");

			FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_EMAIL_COMPLETE, signInWithEmailAndPassword_completeHandler);
			FirebaseAuth.service.signInWithEmailAndPassword(email, password);

		} else {
			trace("Already signed in");

			getCurrentUser();

		}
	}
}



function signInWithEmailAndPassword_completeHandler(event: FirebaseAuthEvent): void {
	trace("signInWithEmailAndPassword(): complete: " + event.success + "::" + event.message);

	if (event.success == true) {

		getCurrentUser();

	}

	if (event.success != true) {
		trace("Invalid Credentials");
		showMessage("Invalid Credentials", "The email and/or password is invalid. Please try again.");
		return;
	}

	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.SIGNIN_WITH_EMAIL_COMPLETE, signInWithEmailAndPassword_completeHandler);

}





//FIREBASE PHONE AUTH
function removeNonNumericChars($str: String): String {
	var newStr: String = "";
	for (var i: int = 0; i < $str.length; i++) {
		var currentCharCode: Number = $str.charCodeAt(i);
		if ((currentCharCode >= 48) && (currentCharCode <= 57)) {
			newStr += $str.charAt(i);
		}
	}
	return newStr;
}


function signInWithPhoneNumber(): void {

	activityDialog.show();

	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.VERIFY_PHONE_NUMBER_FAILED, verifyPhoneNumber_failedHandler);
	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.VERIFY_PHONE_NUMBER_CODE_SENT, verifyPhoneNumber_codeSentHandler);
	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithPhoneNumber_completeHandler);

	phoneNumber = removeNonNumericChars(phoneNumber);
	trace("PHONE: " + phoneNumber);

	FirebaseAuth.service.verifyPhoneNumber("+1" + phoneNumber, 60);
}



function verifyPhoneNumber_failedHandler(event: FirebaseAuthEvent): void {
	trace("verifyPhoneNumber: failed: " + event.message);
	//activityDialog.dismiss();
}


function verifyPhoneNumber_codeSentHandler(event: FirebaseAuthEvent): void {
	activityDialog.dismiss();

	trace("PHONE_CODE_SENT, verificationId = " + event.verificationId);
	phoneVerifyID = event.verificationId;

	//  Here we should save the verification id somewhere persistent
	//  in case the application crashes or something else occurs while
	//  the user is getting the sms code from their message application.
	//
	//  Then we should display an input for the sms code

	if (signUpType == "code") {
		trace("Sending another code");
		return;
	}


}


function verifySMSCode(): void {
	trace("signInWithCredential( " + phoneVerifyID + ", " + smsCode + " )");

	activityDialog.show();

	var credential: PhoneAuthCredential = PhoneAuthProvider.getCredential(phoneVerifyID, smsCode);
	FirebaseAuth.service.signInWithCredential(credential);

}


function signInWithPhoneNumber_completeHandler(event: FirebaseAuthEvent): void {
	trace("signInWithPhoneNumber: complete: " + event.success);
	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.VERIFY_PHONE_NUMBER_FAILED, verifyPhoneNumber_failedHandler);
	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.VERIFY_PHONE_NUMBER_CODE_SENT, verifyPhoneNumber_codeSentHandler);
	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithPhoneNumber_completeHandler);


	if (event.success != true) {
		showMessage("Invalid Code", "The verification code you entered is invalid. Please try again.");
		return;
	}

	activityDialog.dismiss();


}






//FIREBASE SIGN IN COMPLETE
function signInWithCredential_completeHandler(event: FirebaseAuthEvent): void {
	FirebaseAuth.service.removeEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithCredential_completeHandler);

	trace(event.type + "::" + event.success + "::" + contentStatus);
	trace(event.message);

	if (event.success != true) {
		showMessage("Sign In Error", event.message);
		return;
	}
}


//INITIALIZE FIREBASE
initFirebase();