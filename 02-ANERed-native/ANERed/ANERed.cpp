#include "ANERed.h"
#include <windows.h> 
#include <stdio.h>

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

FREContext  AIRContext; // Used to dispatch event back to AIR

extern "C" {

	#pragma comment(linker,"\"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

	#include <red.h>

	red_error lastError;

	void sendPrint(const char* message) {
		FREDispatchStatusEventAsync(AIRContext, (const uint8_t *)"RED_PRINT", (const uint8_t *)message);
	}

	bool hasThrownException(FREObject exception) {
		if(exception != NULL) {
			// Check if we caught a valid exception object first:
			FREObjectType objectType;
			if ( FRE_OK != FREGetObjectType( exception, &objectType ) )
			{
				sendPrint("but failed to obtain information about its type\n");
				return true;
			}
			// If the exception object is valid,
			// then get the exception information as a string:
			if ( FRE_TYPE_OBJECT == objectType )
			{
				FREObject exceptionTextAS = NULL;
				FREObject newException = NULL;

				if ( FRE_OK != FRECallObjectMethod(exception,(const uint8_t *) "toString",	0, NULL, &exceptionTextAS, &newException ) )
				{
					sendPrint("but failed to obtain information about it\n");
					return true;
				}
				
				// Send an event to ActionScript with information on the exception:
				const uint8_t * formatedString;
				uint32_t len = -1;
				FREGetObjectAsUTF8(exceptionTextAS, &len, &formatedString);

				sendPrint(strcat("ERROR: ", strcat ((char *)formatedString, "\n")));
				return true;
			}
		}
		return false;
	}

	/*
	const char * getTypeName(FREObject object) {
		if(object == NULL) return "no-object";
		FREObjectType objectType;
		if ( FRE_OK == FREGetObjectType( object, &objectType) && objectType < 9 ) {
			return OBJECT_TYPES[(int)objectType];
		}
		return "unknown";
	}*/

	red_unset AIR_Print(red_string data) {
		FREResult result;

		FREObject callResult;
		FREObject exception;
		FREObject args[1];

		FREObject ctx;
		FREGetContextActionScriptData(AIRContext, &ctx);
			
		const char * outStr = redCString(data);
		if(FRE_OK == FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &args[0])) {
			result = FRECallObjectMethod(ctx, (const uint8_t *)"print", 1, args, &callResult, &exception);
			hasThrownException(exception);
		}
		return redUnset();
	}

	red_integer AIR_DispatchStatusEventAsync(red_string status, red_string data) {
		FREResult result;
		result = FREDispatchStatusEventAsync(AIRContext, (const uint8_t *)redCString(status), (const uint8_t *)redCString(data));
		return redInteger((int)result);
	}
    
	
	


    DEFINE_ANE_FUNCTION(Red_Init) {
		FREObject result;
		bool bRet = true;
        
		redOpen();
	//	redOpenDebugConsole();
	//	redCloseDebugConsole();

		redRoutine(redWord("&AIR_DispatchStatusEventAsync"), "[status [string!] data [string!]]", (red_integer) &AIR_DispatchStatusEventAsync);
		redRoutine(redWord("&AIR_Print"), "[value [string!]]", (red_unset) &AIR_Print);

	/*	if (lastError = redHasError()) {
			const char* str = redCString((red_string)lastError);
			airDispatchStatusEventAsync("ON_RED", "error");
			//redPrint(err);
		}
	*/
		//Redefining original Red functions to use AIR callbacks:
		redDo(
			"air-print: func[{Outputs a value followed by a newline.} value [any-type!]][if block? value [value: reduce value] &AIR_Print append form value lf] "
			"air-prin:  func[{Outputs a value.} value [any-type!]][if block? value [value: reduce value] &AIR_Print form value] "
			"air-probe: func[{Returns a value after printing its molded form} value [any-type!]][print mold :value :value] "
			"print: :air-print "
			"prin: :air-prin "
			"probe: :air-probe ");

		FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	DEFINE_ANE_FUNCTION(Red_Do) {
		FREObject result;
		bool bRet = true;
		uint32_t len = 0;
		const char * outStr;
		const uint8_t * inStr = NULL;

		if (FREGetObjectAsUTF8(argv[0], &len, &inStr) == FRE_OK) {
			red_value rs = redDo((const char *)inStr);
			if (lastError = redHasError()) {
				outStr = redFormError();
				if(NULL!=outStr) FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
			} else if(rs != NULL) {
				int type = redTypeOf(rs);

				FREObject ctx;
				FREObject exception;

				FREGetContextActionScriptData(AIRContext, &ctx);
				FRENewObjectFromInt32(type, &result);
				FRESetObjectProperty(ctx, (const uint8_t *)"lastResultType", result, &exception);
				hasThrownException(exception);

				switch(type) {
					//case RED_TYPE_STRING:
					//	outStr = redCString(rs);
					//	if(NULL!=outStr) FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
					//	break;
					case RED_TYPE_LOGIC:
						FRENewObjectFromBool((int)redCInt32(rs), &result);
						break;
					case RED_TYPE_INTEGER:
						FRENewObjectFromInt32((int)redCInt32(rs), &result);
						break;
					case RED_TYPE_FLOAT:
						FRENewObjectFromDouble((double)redCDouble(rs), &result);
						break;
					case RED_TYPE_NONE:
						//do nothing to return NULL
						break;
					//TODO: support more direct value conversions?
					default:
						outStr = redCString(redCall(redWord("mold"), rs, 0));
						if(NULL!=outStr) FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
					
				}
			}
		}
		//FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	DEFINE_ANE_FUNCTION(Red_DoEventLoop) {
		redDo("system/view/platform/do-event-loop true");
		return NULL;
	}

	DEFINE_ANE_FUNCTION(Red_GetLastError) {
		FREObject result;
		if (NULL != lastError) {
			red_value rs = redCall(redWord("form"), lastError, 0);
			if(rs != NULL) {
				const char * outStr = redCString(rs);
				if(NULL!=outStr) FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
			}
			lastError = NULL;
		}
		return result;
	}

	DEFINE_ANE_FUNCTION(Red_RegisterCallbacks) {
		FREObject result;
		FREObject AIRCallbacks = argv[0];
		FREResult r = FRESetContextActionScriptData(context, AIRCallbacks);
		FRENewObjectFromInt32(r, &result);
		return result;
	}
    
    // A native context instance is created
    void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                            uint32_t* numFunctions, const FRENamedFunction** functions) {
        static FRENamedFunction extensionFunctions[] = {
            { (const uint8_t*) "Init",  NULL, Red_Init},
			{ (const uint8_t*) "redDo", NULL, Red_Do},
			{ (const uint8_t*) "redGetLastError", NULL, Red_GetLastError},
			{ (const uint8_t*) "redDoEventLoop", NULL, Red_DoEventLoop},
			{ (const uint8_t*) "redRegisterCallbacks", NULL, Red_RegisterCallbacks},
        };
        
        *numFunctions = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
        *functions = extensionFunctions;
        AIRContext = ctx;
    }
    
    // A native context instance is disposed
    void ContextFinalizer(FREContext ctx) {
		redClose();
        AIRContext = NULL;
        return;
    }
    
    // Initialization function of each extension
    EXPORT void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                               FREContextFinalizer* ctxFinalizerToSet) {
        *extDataToSet = NULL;
        *ctxInitializerToSet = &ContextInitializer;
        *ctxFinalizerToSet = &ContextFinalizer;
    }
    
    // Called when extension is unloaded
    EXPORT void ExtFinalizer(void* extData) {
        return;
    }
}
