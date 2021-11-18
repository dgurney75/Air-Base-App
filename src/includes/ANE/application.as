//IMPORT APPLICATION ANE CLASSES
import com.distriqt.extension.application.Application;
import com.distriqt.extension.application.ApplicationDisplayModes;
import com.distriqt.extension.application.AuthorisationStatus;
import com.distriqt.extension.application.IDType;
import com.distriqt.extension.application.StatusBarStyle;
import com.distriqt.extension.application.display.AndroidSystemUiFlags;
import com.distriqt.extension.application.display.DisplayMode;
import com.distriqt.extension.application.display.LayoutMode;
import com.distriqt.extension.application.display.NavigationBarStyle;
import com.distriqt.extension.application.events.ApplicationEvent;
import com.distriqt.extension.application.events.ApplicationStateEvent;
import com.distriqt.extension.application.events.AuthorisationEvent;
import com.distriqt.extension.application.events.DefaultsEvent;
import com.distriqt.extension.application.events.DeviceOrientationEvent;
import com.distriqt.extension.application.events.DeviceStateEvent;
import com.distriqt.extension.application.events.SettingsEvent;




trace("DEVICE INFO ============================");
trace(" name:         " + Application.service.device.name);
trace(" brand:        " + Application.service.device.brand);
trace(" manufacturer: " + Application.service.device.manufacturer);
trace(" device:       " + Application.service.device.device);
trace(" model:        " + Application.service.device.model);
trace(" yearClass:    " + Application.service.device.yearClass);
trace(" product:      " + Application.service.device.product);


trace("OPERATING SYSTEM =======================");
trace(" name:         " + Application.service.device.os.name);
trace(" type:         " + Application.service.device.os.type);
trace(" version:      " + Application.service.device.os.version);
trace(" API Level:    " + Application.service.device.os.api_level);




//USE KEYCHAIN ENCRYPTION IF AVAILABLE (iOS)
if (Application.service.keychain.isSupported) {
	trace("KEYCHAIN SUPPORTED");
}


//OPEN APP SETTINGS
function openAppSettings(): void {
	if (Application.service.settings.isSupported) {
		// Settings functionality is available
		Application.service.settings.openSettingsScreen();
	}
}



//
//	CHANGE STATUS BAR
//

var statusBarType = "default";

//IOS 
function hideStatusBar(): void {
	Application.service.display.setStatusBarHidden(true);
}

function showStatusBar(): void {
	Application.service.display.setStatusBarHidden(false);
}


function setStatusBarType(): void {
	if (statusBarType == "light") {
		Application.service.display.setStatusBarStyle(StatusBarStyle.LIGHT);
	}

	if (statusBarType == "default") {
		Application.service.display.setStatusBarStyle(StatusBarStyle.DEFAULT);
	}
}



//ANDROID 
Application.service.display.setDisplayMode(DisplayMode.IMMERSIVE, LayoutMode.CUTOUT_SHORT_EDGES);


//ANDROID BLACK BAR FIX
var _deactivated: Boolean = false;

function deactivateHandler(event: Event): void {
	_deactivated = true;
}

function activateHandler(event: Event): void {
	if (_deactivated) {
		_deactivated = false;
		Application.service.blackScreenHelper();
	}
}



//UNIQUE ID FOR DEVICE
var deviceID: String = "debug";
deviceID = Application.service.device.uniqueId(IDType.VENDOR, true);

if (deviceID == null || deviceID == "") {
	deviceID = "debug";
}

trace("Device ID: " + deviceID);




//GET DEVICE SETTINGS
var device: String;
var OS: String;
var brand: String;
var appType: String;

device = Application.service.device.brand + " " + Application.service.device.model;
OS = Application.service.device.os.name + " " + Application.service.device.os.version;
appType = Application.service.device.os.name;


trace("Device is: " + device);
if (device == "unknown unknown") {
	device = "Device not recognized";
}

trace("OS is: " + OS);
trace("AppType is: " + appType);

// CHECK DEVICE RESOLUTION & MAKE ADJUSTMENTS TO INTERFACE
var nativeHeight: Number = Capabilities.screenResolutionY;
var nativeWidth: Number = Capabilities.screenResolutionX;

trace("NATIVE WIDTH: " + nativeWidth);
trace("NATIVE HEIGHT: " + nativeHeight);

var winHeight: Number;

//USE THIS FOR DEVICE UI ADJUSTMENTS
winHeight = nativeHeight / nativeWidth * 390;
trace("DEVICE HEIGHT: " + winHeight);


//USE THIS IF TESTING ON DESKTOP
if (winHeight < 400) {
	appType = "iOS";
	winHeight = 844;
}




//CHECK IF APP IS IN FOREGROUND OR BACKGROUND
Application.service.addEventListener(ApplicationStateEvent.ACTIVATE, stateEventHandler);
Application.service.addEventListener(ApplicationStateEvent.DEACTIVATE, stateEventHandler);
Application.service.addEventListener(ApplicationStateEvent.FOREGROUND, stateEventHandler);
Application.service.addEventListener(ApplicationStateEvent.BACKGROUND, stateEventHandler);


function stateEventHandler(event: ApplicationStateEvent): void {
	trace(event.type + "::" + event.code);

	if (event.type == "applicationstate:background") {

		// Your application is in the background
		NativeApplication.nativeApplication.executeInBackground = true;
		trace("APP IS RUNNING IN BACKGROUND");
		startDate = new Date();
		trace(startDate);

	}

	if (event.type == "applicationstate:foreground") {

		// Your application is in the foreground
		trace("APP IS RUNNING IN FOREGROUND");

		if (contentStatus == "login") {
			return;
		}

		endDate = new Date();
		trace(endDate);

		timeDifference(startDate, endDate);
	}

}



//LOGOUT IF APP IS IDLE FOR 20 MINUTES
var startDate: Date;
var endDate: Date;

function timeDifference(startTime: Date, endTime: Date): String {
	if (startTime == null) {
		return "startTime empty.";
	}
	if (endTime == null) {
		return "endTime empty.";
	}

	var aTms: * = Math.floor(endTime.valueOf() - startTime.valueOf());
	var timeTaken: * = (int(aTms / (60 * 60 * 1000)) % 24);

	trace("TIME TAKEN: " + String(int(aTms / (60 * 1000))) + " minutes");

	if (int(aTms / (60 * 1000)) >= 20) {

		trace("LOGOUT DUE TO INACTIVITY");

		contentStatus = "logout";
		gotoAndPlay("logoutUser", "login");

		//DIALOG ANE USED HERE
		showMessage("USER LOGGED OUT", "You have been logged out due to inactivity");

	}

	return "Time taken:  " + String(int(aTms / (60 * 1000))) + " minutes";

}