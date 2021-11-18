import com.distriqt.extension.applesignin.AppleIDCredential;
import com.distriqt.extension.applesignin.AppleSignIn;
import com.distriqt.extension.applesignin.AppleSignInOptions;
import com.distriqt.extension.applesignin.AppleSignInScopes;
import com.distriqt.extension.applesignin.events.AppleSignInErrorEvent;
import com.distriqt.extension.applesignin.events.AppleSignInEvent;
import com.distriqt.utils.Base64;


try {
	trace("AppleSignIn Supported: " + AppleSignIn.isSupported);
	if (AppleSignIn.isSupported) {
		trace("AppleSignIn Version:   " + AppleSignIn.service.version);
	}
} catch (e: Error) {
	trace(e);
}



////////////////////////////////////////////////////////
//	APPLE SIGN IN (DOES NOT WORK WITH APPLE ENTERPRISE ACCOUNTS)
//


var _user: String;
var _credential: AppleIDCredential;


function appleSignIn(): void {

	//ANDROID SIGN-IN
	if (FirebaseAuth.service.implementation == "Android") {
		
		FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_PROVIDER_COMPLETE, startSignInWithProvider_completeHandler);

		var provider: OAuthProvider = new OAuthProvider("apple.com")
			.setScopes(["email", "name"]);

		FirebaseAuth.service.startSignInWithProvider(provider);
		return;
	}


    //APPLE SIGN-IN
	AppleSignIn.instance.addEventListener(AppleSignInErrorEvent.ERROR, appleSignIn_errorHandler);
	AppleSignIn.service.addEventListener(AppleSignInEvent.SUCCESS, appleSignIn_successHandler);

	var options: AppleSignInOptions = new AppleSignInOptions()
		.setRequestedScopes([
			AppleSignInScopes.FULL_NAME,
			AppleSignInScopes.EMAIL
		])

	//SERVICE ID
	.setClientId("com.maritz.baseAppSignIn")
	.setRedirectUrl("https://air-base-app.firebaseapp.com/__/auth/handler");

	AppleSignIn.service.loginWithAppleId(options);

}

//ANSDORID SIGN-IN COMPLETE
function startSignInWithProvider_completeHandler(event: FirebaseAuthEvent): void {
	// End of the Android sign in process
	trace("startSignInWithProvider_completeHandler():complete:" + event.success);

}



//FINISH SIGNING INTO FIREBASE
function appleSignIn_successHandler(event: AppleSignInEvent): void {

	trace("user: " + event.appleIdCredential.user);
	trace("identityToken: " + event.appleIdCredential.identityToken);
	trace("authorizationCode: " + event.appleIdCredential.authorizationCode);
	trace("raw Nonce: " + event.rawNonce);

	var credential: OAuthCredential = OAuthProvider.getCredential("apple.com")
		.setIdTokenWithRawNonce(
			Base64.decode(event.appleIdCredential.identityToken),
			event.rawNonce
	);

	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithCredential_completeHandler);

	FirebaseAuth.service.signInWithCredential(credential);
}

function appleSignIn_errorHandler(event: AppleSignInErrorEvent): void {
	trace("errorHandler(): [" + event.errorID + "] :: " + event.text);
}