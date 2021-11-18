import com.distriqt.extension.facebook.core.Facebook;
import com.distriqt.extension.facebook.login.AccessToken;
import com.distriqt.extension.facebook.login.AuthenticationToken;
import com.distriqt.extension.facebook.login.FacebookLogin;
import com.distriqt.extension.facebook.login.LoginConfiguration;
import com.distriqt.extension.facebook.login.LoginTracking;
import com.distriqt.extension.facebook.login.Profile;
import com.distriqt.extension.facebook.login.events.FacebookAccessTokenEvent;
import com.distriqt.extension.facebook.login.events.FacebookLoginErrorEvent;
import com.distriqt.extension.facebook.login.events.FacebookLoginEvent;
import com.distriqt.extension.facebook.login.events.FacebookProfileEvent;




try {

	trace("FacebookCore Supported: " + Facebook.isSupported);
	trace("FacebookLogin Supported: " + FacebookLogin.isSupported);

	if (Facebook.isSupported) {
		trace("core.version:           " + Facebook.instance.version);
		trace("core.nativeVersion:     " + Facebook.instance.nativeVersion);
		trace("sdk version:            " + Facebook.instance.getSDKVersion());
		trace("isFacebookAppInstalled: " + Facebook.instance.isFacebookAppInstalled());
	}

	if (FacebookLogin.isSupported) {
		trace("isLoggedIn:   " + FacebookLogin.service.isLoggedIn());

		FacebookLogin.instance.addEventListener(FacebookLoginEvent.SUCCESS, facebookSuccessHandler);
		FacebookLogin.instance.addEventListener(FacebookLoginEvent.CANCEL, facebookCancelHandler);

		FacebookLogin.instance.addEventListener(FacebookLoginErrorEvent.ERROR, facebookErrorHandler);

		FacebookLogin.instance.addEventListener(FacebookProfileEvent.CHANGED, profileChangedHandler);
		FacebookLogin.instance.addEventListener(FacebookAccessTokenEvent.CHANGED, accessTokenChangedHandler);


	}

} catch (e: Error) {
	trace(e);
}



////////////////////////////////////////////////////////
//  INITIALIZE FACBOOK API
//


if (Facebook.isSupported) {
	Facebook.instance.setAutoInitEnabled(true);
	Facebook.instance.initialise();

	trace("sdk version:            " + Facebook.instance.getSDKVersion());
	trace("isFacebookAppInstalled: " + Facebook.instance.isFacebookAppInstalled());

}




// FACEBOOK SIGN IN
function facebookSignIn(): void {
	trace("login");
	if (FacebookLogin.isSupported) {
		FacebookLogin.instance.logInWithConfiguration(
			new LoginConfiguration(["public_profile", "email"])
			//.setLoginTracking( LoginTracking.LIMITED )
			.setNonce("123")
		);
	}
}


function checkState(): void {
	if (FacebookLogin.isSupported) {
		trace("isLoggedIn: " + FacebookLogin.service.isLoggedIn());
	}
}


function getAccessToken(): void {
	trace("getAccessToken");
	if (FacebookLogin.isSupported) {
		var accessToken: AccessToken = FacebookLogin.instance.getAccessToken();
		logAccessToken(accessToken);
	}
}


function getProfile(): void {
	trace("getProfile");
	if (FacebookLogin.isSupported) {
		var profile: Profile = FacebookLogin.instance.getProfile();
		logProfile(profile);
	}
}


function getAuthToken(): void {
	trace("getAuthToken");
	if (FacebookLogin.isSupported) {
		var authToken: AuthenticationToken = FacebookLogin.instance.getAuthenticationToken();
		logAuthToken(authToken);
	}
}


function facebookSignOut(): void {
	trace("logout");
	if (FacebookLogin.isSupported) {
		FacebookLogin.instance.logout();
	}
}



//
// EVENT HANDLERS
//

function facebookSuccessHandler(event: FacebookLoginEvent): void {
	trace("successHandler()");
	logAccessToken(event.accessToken);
	logProfile(event.profile);
	logAuthToken(event.authToken);
	
	//PASS ID TOKEN TO FIREBASE AUTH TO SIGN IN
	var credential: AuthCredential = FacebookAuthProvider.getCredential(event.accessToken.token);

	FirebaseAuth.service.addEventListener(FirebaseAuthEvent.SIGNIN_WITH_CREDENTIAL_COMPLETE, signInWithCredential_completeHandler);
	FirebaseAuth.service.signInWithCredential(credential);
	
	getProfile();
}


function facebookCancelHandler(event: FacebookLoginEvent): void {
	trace("cancelHandler()");
}


function facebookErrorHandler(event: FacebookLoginErrorEvent): void {
	trace("errorHandler() : " + event.text + event.errorID);
}


function profileChangedHandler(event: FacebookProfileEvent): void {
	trace("profileChangedHandler()");
	logProfile(event.profile);
}

function accessTokenChangedHandler(event: FacebookAccessTokenEvent): void {
	trace("accessTokenChangedHandler()");
	logAccessToken(event.accessToken);
}





function logAccessToken(accessToken: AccessToken): void {
	if (accessToken != null) {
		trace("accessToken = " + accessToken.token);
	} else {
		trace("accessToken = null");
	}
}


function logProfile(profile: Profile): void {
	if (profile != null) {
		trace("profile.name    = " + profile.name);
		trace("profile.linkUrl = " + profile.linkUrl);
	} else {
		trace("profile = null");
	}
}


function logAuthToken(authToken: AuthenticationToken): void {
	if (authToken != null) {
		trace("authToken.token = " + authToken.token);
		trace("authToken.nonce = " + authToken.nonce);
		trace("authToken.graph = " + authToken.graphDomain);
	} else {
		trace("authToken = null");
	}
}
