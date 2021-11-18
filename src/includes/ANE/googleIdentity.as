import com.distriqt.extension.core.Core;
import com.distriqt.extension.googleidentity.GoogleIdentity;
import com.distriqt.extension.googleidentity.GoogleIdentityOptions;
import com.distriqt.extension.googleidentity.GoogleIdentityOptionsBuilder;
import com.distriqt.extension.googleidentity.GoogleUser;
import com.distriqt.extension.googleidentity.events.GoogleIdentityEvent;


Core.init();

trace("GoogleIdentity Supported: " + GoogleIdentity.isSupported);
trace("GoogleIdentity Version:   " + GoogleIdentity.service.version);

GoogleIdentity.service.addEventListener(GoogleIdentityEvent.SIGN_IN, signInHandler);
GoogleIdentity.service.addEventListener(GoogleIdentityEvent.SIGN_OUT, signOutHandler);
GoogleIdentity.service.addEventListener(GoogleIdentityEvent.ERROR, errorHandler);

var options: GoogleIdentityOptions = new GoogleIdentityOptionsBuilder()
	.requestIdToken()
	.setIOSClientID("610224678821-93t38ocnkia6c9teh5pdle0752ogk3oi.apps.googleusercontent.com")
	.setServerClientID("610224678821-kff6ekg2fvcu11s1s3b6hm5m2fdl2koh.apps.googleusercontent.com")
	.build();

GoogleIdentity.service.setup(options);


//
//	EVENT HANDLERS
//


//	GOOGLE AUTH SIGN IN
function googleSignIn(): void {
	trace("Google signIn()  ");
	GoogleIdentity.service.signIn();
}


//	GOOGLE AUTH SIGN OUT
function googleSignOut(): void {
	GoogleIdentity.service.addEventListener(GoogleIdentityEvent.SIGN_OUT, signOutHandler);
	GoogleIdentity.service.signOut();
}



//
//	EXTENSION HANDLERS
//

function setupCompleteHandler(event: GoogleIdentityEvent): void {
	trace(event.type);

	trace("isSignedIn=" + GoogleIdentity.service.isSignedIn());

	var user: GoogleUser = GoogleIdentity.service.getUser();

	if (user != null) {
		trace(user.toString());
	} else {
		trace("not signed in");
	}

	GoogleIdentity.service.signInSilently();
}

function signInHandler(event: GoogleIdentityEvent): void {
	trace(event.type + "::" + event.user.toString());
	trace("idToken: " + event.user.authentication.idToken);

	trace("Google Sign in success");

	//PASS ID TOKEN TO FIREBASE AUTH TO SIGN IN
	var credential: AuthCredential = GoogleAuthProvider.getCredential(event.user.authentication.idToken, null);

	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithCredential_completeHandler);
	FirebaseAuth.service.signInWithCredential(credential);
}

function signOutHandler(event: GoogleIdentityEvent): void {
	trace(event.type);
}

function errorHandler(event: GoogleIdentityEvent): void {
	trace(event.type + "::" + event.errorCode + "::" + event.error);
}