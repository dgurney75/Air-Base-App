//IMPORT WEBVIEW ANE CLASSES
import com.distriqt.extension.nativewebview.*;
import com.distriqt.extension.nativewebview.CachePolicy;
import com.distriqt.extension.nativewebview.NativeWebView;
import com.distriqt.extension.nativewebview.PrintOptions;
import com.distriqt.extension.nativewebview.WebView;
import com.distriqt.extension.nativewebview.WebViewOptions;
import com.distriqt.extension.nativewebview.events.NativeWebViewEvent;
import com.distriqt.extension.nativewebview.browser.BrowserView;
import com.distriqt.extension.nativewebview.browser.BrowserViewOptions
import com.distriqt.extension.nativewebview.events.BrowserViewEvent;



//CHECK SUPPORT
try {
	trace("NativeWebView Supported: " + NativeWebView.isSupported);
	trace("NativeWebView Version:   " + NativeWebView.service.version);

} catch (e: Error) {
	trace("ERROR::" + e.message);
}


//DEFINE WEBVIEW VARS
var urlID: String = "";

var bvOptions: BrowserViewOptions = new BrowserViewOptions();

bvOptions.animationIn = BrowserViewOptions.SLIDE_LEFT;
bvOptions.animationOut = BrowserViewOptions.SLIDE_RIGHT;


//NATIVE BROWSER SUPPORT
if (NativeWebView.service.browserView.isSupported) {

	NativeWebView.service.browserView.addEventListener(BrowserViewEvent.READY, browserView_readyHandler);
	NativeWebView.service.browserView.prepare();
}


//INITIALIZE NATIVE BROWSER
function browserView_readyHandler(event: BrowserViewEvent): void {
	NativeWebView.service.browserView.removeEventListener(BrowserViewEvent.READY, browserView_readyHandler);

}

//SET NATIVE BROWSER EVENT LISTENERS
NativeWebView.service.browserView.addEventListener(BrowserViewEvent.CLOSED, browserView_eventHandler);
NativeWebView.service.browserView.addEventListener(BrowserViewEvent.OPENED, browserView_eventHandler);
NativeWebView.service.browserView.addEventListener(BrowserViewEvent.LOADED, browserView_eventHandler);
NativeWebView.service.browserView.addEventListener(BrowserViewEvent.ERROR, browserView_eventHandler);


//OPEN NATIVE BROWSER
function openBrowserView(): void {

	//NO URL FOUND
	if (urlID == "") {
		return;
	}

	//NATIVE BROWSER SUPPORTED
	if (NativeWebView.service.browserView.isSupported) {

		if (urlID.indexOf("?") == -1) {
			urlID = urlID + "?dateTime=" + new Date().getTime();
		} else
		if (!urlID.match(/\?$/)) {
			urlID = urlID + "&dateTime=" + new Date().getTime();
		}

		NativeWebView.service.browserView.openWithUrl(urlID);
		trace("URL: " + urlID);
		return;
	}
}


//NATIVE BROWSER CLOSED
function browserView_eventHandler(event: BrowserViewEvent): void {

	trace("browserView_eventHandler( " + event.type + " )");

	if (event.type == "browserView:closed") {
		urlID = "";
		stage.autoOrients = false;
	}

	if (event.type == "browserView:loaded") {
		//REMOVE LOADER ANIMATION
		activityDialog.dismiss();
		stage.autoOrients = true;
	}
}


