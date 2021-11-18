
//IMPORT CORE CLASSES
import flash.system.Capabilities;
import flash.utils.Timer;
import flash.text.TextField;


//GREENSOCK ANIMATION CLASSES
import com.greensock.*;
import com.greensock.easing.*;


//DEFINE APP VERSION HERE		
var appVersionLocal = "1.0.0";


//DEFINE APP ENVIRONMENT HERE (stage or prod) FOR DATA
var appEnvironment: String = "stage";


// SET ALIGNMENT / SCALE PROPERTIES FOR MOBILE
stage.align = "t";
stage.scaleMode = StageScaleMode.NO_BORDER;
stage.displayState = StageDisplayState.NORMAL;


//DEFINE APP STATUS
var contentStatus: String = "login";
var actionStatus: String = "noAction";


//DEFINE BASE COLORS
var primaryColor:String = "E02728";
var secondaryColor:String = "000000";