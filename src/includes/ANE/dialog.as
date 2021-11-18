import com.distriqt.extension.dialog.DateTimeDialogView;
import com.distriqt.extension.dialog.Dialog;
import com.distriqt.extension.dialog.DialogTheme;
import com.distriqt.extension.dialog.DialogType;
import com.distriqt.extension.dialog.DialogView;
import com.distriqt.extension.dialog.Gravity;
import com.distriqt.extension.dialog.PickerDialogView;
import com.distriqt.extension.dialog.ProgressDialogView;
import com.distriqt.extension.dialog.builders.ActionSheetBuilder;
import com.distriqt.extension.dialog.builders.ActivityBuilder;
import com.distriqt.extension.dialog.builders.AlertBuilder;
import com.distriqt.extension.dialog.builders.DateTimeDialogBuilder;
import com.distriqt.extension.dialog.builders.MultiSelectBuilder;
import com.distriqt.extension.dialog.builders.PickerDialogBuilder;
import com.distriqt.extension.dialog.builders.ProgressDialogBuilder;
import com.distriqt.extension.dialog.builders.TextViewAlertBuilder;
import com.distriqt.extension.dialog.events.DialogDateTimeEvent;
import com.distriqt.extension.dialog.events.DialogViewEvent;
import com.distriqt.extension.dialog.events.PopoverEvent;
import com.distriqt.extension.dialog.objects.DialogAction;
import com.distriqt.extension.dialog.objects.PopoverOptions;


//ALERTS DIALOG WIN
var alertTitleTXT: String;
var alertTXT: String;
var updateURL: String;
var buttonText: String = "";
var sendAgain = "";


try {
	trace("Dialog Supported:      " + Dialog.isSupported);
	trace("Dialog Version:        " + Dialog.service.version);
	trace("Dialog Implementation: " + Dialog.service.implementation);

	Dialog.service.setDefaultTheme(new DialogTheme(DialogTheme.DEVICE_DEFAULT));

} catch (e: Error) {
	trace("ERROR::" + e.message);
}


Dialog.service.root = stage;


//LOADING CONTENT ANIMATION
var activityDialog: DialogView = Dialog.service.create(
	new ActivityBuilder()
	.setTheme(new DialogTheme(DialogTheme.DEVICE_DEFAULT_DARK))
	//.setStyle( DialogType.STYLE_SPINNER )
	.build()
);


var _cancelable: Boolean = false;

function toggleCancelable(): void {
	_cancelable = !_cancelable;
	trace("cancelable=" + _cancelable);
}

function showMessage(title: String, errorMessage: String): void {
	trace("showAlertDialog");
	activityDialog.dismiss();

	if (buttonText == "" || buttonText == null) {
		buttonText = "Ok";
	}

	var alert: DialogView = Dialog.service.create(
		new AlertBuilder()
		.setTitle(title)
		.setMessage(errorMessage)
		.addOption(buttonText)
		.build()
	);

	alert.addEventListener(DialogViewEvent.CLOSED, function (event: DialogViewEvent): void {
		trace("alert closed: " + event.index);
		var v: DialogView = DialogView(event.currentTarget);
		v.removeEventListener(DialogViewEvent.CLOSED, arguments.callee);
		v.dispose();
	});

	alert.show();
}
