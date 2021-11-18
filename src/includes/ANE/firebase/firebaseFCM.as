import com.distriqt.extension.playservices.base.ConnectionResult;
import com.distriqt.extension.playservices.base.GoogleApiAvailability;
import com.distriqt.extension.pushnotifications.PushNotifications;
import com.distriqt.extension.pushnotifications.Service;
import com.distriqt.extension.pushnotifications.builders.ActionBuilder;
import com.distriqt.extension.pushnotifications.builders.CategoryBuilder;
import com.distriqt.extension.pushnotifications.builders.ChannelBuilder;
import com.distriqt.extension.pushnotifications.channels.ChannelGroup;
import com.distriqt.extension.pushnotifications.events.AuthorisationEvent;
import com.distriqt.extension.pushnotifications.events.PushNotificationEvent;
import com.distriqt.extension.pushnotifications.events.PushNotificationGroupEvent;
import com.distriqt.extension.pushnotifications.events.RegistrationEvent;

var pushtrace = "";
var pushActive;
var pushToken;



function initFCM(): void {
	if (PushNotifications.isSupported) {
		trace("PushNotifications.version = " + PushNotifications.service.version);

		trace("PushNotifications.isServiceSupported( " + Service.FCM + " ) = " + PushNotifications.service.isServiceSupported(Service.FCM));
		//trace("PushNotifications.isServiceSupported( " + Service.APNS + " ) = " + PushNotifications.service.isServiceSupported(Service.APNS));

		var service: Service;


		service = new Service(Service.FCM)
			.setNotificationsWhenActive(true)
			.setShouldRequestCriticalAlerts(true);

		service.sandboxMode = false;
		service.setNotificationsWhenActive(true);

		PushNotifications.service.setup(service);
		
		PushNotifications.service.addEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);

		// Check the authorisation state again (as above)
		trace("STATUS: " + PushNotifications.service.authorisationStatus());

		switch (PushNotifications.service.authorisationStatus()) {
			case AuthorisationStatus.AUTHORISED:
				// This device has been authorised.
				// You can register this device and expect:
				//	- registration success/failed event, and; 
				// 	- notifications to be displayed
				registerPush()
				break;

			case AuthorisationStatus.NOT_DETERMINED:
				// You are yet to ask for authorisation to display notifications
				// At this point you should consider your strategy to get your user to authorise
				// notifications by explaining what the application will provide
				PushNotifications.service.requestAuthorisation();
				break;

			case AuthorisationStatus.DENIED:
				// The user has disabled notifications
				// Advise your user of the lack of notifications as you see fit

				// For example: You can redirect to the settings page on iOS
				if (PushNotifications.service.canOpenDeviceSettings) {
					PushNotifications.service.openDeviceSettings();
				}
				break;
		}
	}
}



function authorisationChangedHandler(event: AuthorisationEvent): void {
	// Check the authorisation state again (as above)
	trace("STATUS: " + PushNotifications.service.authorisationStatus());


	switch (PushNotifications.service.authorisationStatus()) {
		case AuthorisationStatus.AUTHORISED:
			// This device has been authorised.
			// You can register this device and expect:
			//	- registration success/failed event, and; 
			// 	- notifications to be displayed
		    registerPush()
			break;

		case AuthorisationStatus.NOT_DETERMINED:
			// You are yet to ask for authorisation to display notifications
			// At this point you should consider your strategy to get your user to authorise
			// notifications by explaining what the application will provide
			PushNotifications.service.requestAuthorisation();
			break;

		case AuthorisationStatus.DENIED:
			// The user has disabled notifications
			// Advise your user of the lack of notifications as you see fit

			// For example: You can redirect to the settings page on iOS
			if (PushNotifications.service.canOpenDeviceSettings) {
				PushNotifications.service.openDeviceSettings();
			}
			break;
	}
}



function registerPush(): void {
	PushNotifications.service.addEventListener(RegistrationEvent.REGISTERING, registeringHandler);
	PushNotifications.service.addEventListener(RegistrationEvent.REGISTER_SUCCESS, registerSuccessHandler);
	PushNotifications.service.addEventListener(RegistrationEvent.CHANGED, registrationChangedHandler);
	PushNotifications.service.addEventListener(RegistrationEvent.REGISTER_FAILED, registerFailedHandler);
	PushNotifications.service.addEventListener(RegistrationEvent.ERROR, errorHandler);

	PushNotifications.service.register();
}


function registeringHandler(event: com.distriqt.extension.pushnotifications.events.RegistrationEvent): void {
	trace("Registration started");
}

function registerSuccessHandler(event: com.distriqt.extension.pushnotifications.events.RegistrationEvent): void {
	trace("Registration succeeded with ID: " + PushNotifications.service.getDeviceToken());
	var deviceTokenOrRegistrationId: String = PushNotifications.service.getDeviceToken();
	
	PushNotifications.service.removeEventListener(RegistrationEvent.REGISTERING, registeringHandler);
	PushNotifications.service.removeEventListener(RegistrationEvent.REGISTER_SUCCESS, registerSuccessHandler);
	PushNotifications.service.removeEventListener(RegistrationEvent.CHANGED, registrationChangedHandler);
	PushNotifications.service.removeEventListener(RegistrationEvent.REGISTER_FAILED, registerFailedHandler);
	PushNotifications.service.removeEventListener(RegistrationEvent.ERROR, errorHandler);
	
	PushNotifications.service.removeEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);
}

function registrationChangedHandler(event: RegistrationEvent): void {
	trace("Registration changed with ID: " + PushNotifications.service.getDeviceToken());
	var deviceTokenOrRegistrationId: String = PushNotifications.service.getDeviceToken();
}

function registerFailedHandler(event: RegistrationEvent): void {
	trace("Registration failed");
}

function errorHandler(event: RegistrationEvent): void {
	trace("Registration error: " + event.data);
}