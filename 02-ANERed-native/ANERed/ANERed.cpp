#include "ANERed.h"
#include <windows.h> 
#include <stdio.h> 

FREContext  AIRContext; // Used to dispatch event back to AIR

extern "C" {
	#include <red.h>

	red_integer airDispatchStatusEventAsync(red_string status, red_string data) {
		FREResult result = FREDispatchStatusEventAsync(AIRContext, (const uint8_t *)redCString(status), (const uint8_t *)redCString(data));
		return redInteger(1);
	}
    
	red_error lastError;

    FREObject Red_Init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;
        
		redOpen();
	//	redOpenDebugConsole();
	//	redCloseDebugConsole();
	//	redProbe(redCall(redWord("what-dir"), 0));
	//	redCall(redWord("print"), redDo("system/version"), 0);
		redRoutine(redWord("FREDispatchStatusEventAsync"), "[status [string!] data [string!]]", (red_integer) &airDispatchStatusEventAsync);
	/*	if (lastError = redHasError()) {
			const char* str = redCString((red_string)lastError);
			airDispatchStatusEventAsync("ON_RED", "error");
			//redPrint(err);
		}
	*/
		redDo(
			"air-print: func[{Outputs a value followed by a newline.} value [any-type!]][if block? value [value: reduce value] FREDispatchStatusEventAsync {RED_PRINT} append form value lf] "
			"air-prin:  func[{Outputs a value.} value [any-type!]][if block? value [value: reduce value] FREDispatchStatusEventAsync {RED_PRINT} form value] "
			"air-probe: func[{Returns a value after printing its molded form} value [any-type!]][print mold :value :value] "
			"print: :air-print "
			"prin: :air-prin "
			"probe: :air-probe ");

		FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	FREObject Red_Do(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;
		uint32_t len = 0;
		const char * outStr;
		const uint8_t * inStr = NULL;

		//redCall(redWord("print"), redDo("system/version"), 0);

		if (FREGetObjectAsUTF8(argv[0], &len, &inStr) == FRE_OK) {
			/*
			int		a = redSymbol("a");
			redSet(a, (red_value) redInteger(42));
			red_value value = redGet(redSymbol("a"));
			int type = redTypeOf(value);
			FRENewObjectFromUint32((uint32_t)type, &result);
			*/
			red_value rs = redDo((const char *)inStr);
			if (lastError = redHasError()) {
				outStr = "ERROR!";
				FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
			} else if(rs != NULL) {
				int type = redTypeOf(rs);

				switch(type) {
					case RED_TYPE_STRING:
						outStr = redCString(rs);
						if(NULL!=outStr) FRENewObjectFromUTF8(strlen(outStr), (const uint8_t *)outStr, &result);
						break;
					//TODO: when result is not string!
					//case RED_TYPE_LOGIC:
					//	const char * outStr = redCString(rs);
					//	if(NULL!=outStr) FRENewObjectFromBool(strlen(outStr), (const uint8_t *)outStr, &result);
				}
			}
		}
		//FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	FREObject Red_GetLastError(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
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
    
    // A native context instance is created
    void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                            uint32_t* numFunctions, const FRENamedFunction** functions) {
        static FRENamedFunction extensionFunctions[] = {
            { (const uint8_t*) "Init",  NULL, Red_Init},
			{ (const uint8_t*) "redDo", NULL, Red_Do},
			{ (const uint8_t*) "redGetLastError", NULL, Red_GetLastError},
        };
        
        *numFunctions = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
        *functions = extensionFunctions;
        AIRContext = ctx;
    }
    
    // A native context instance is disposed
    void ContextFinalizer(FREContext ctx) {
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
