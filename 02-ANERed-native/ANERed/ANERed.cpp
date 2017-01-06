#include "ANERed.h"
#include <windows.h> 
#include <stdio.h> 

FREContext  AIRContext; // Used to dispatch event back to AIR

extern "C" {
	#include <red.h>

	
    
    FREObject Red_Init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;
        
		redOpen();

		FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	FREObject Red_Do(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;
		uint32_t len = 0;
		const uint8_t * inStr = NULL;

		if (FREGetObjectAsUTF8(argv[0], &len, &inStr) == FRE_OK) {
			/*
			int		a = redSymbol("a");
			redSet(a, (red_value) redInteger(42));
			red_value value = redGet(redSymbol("a"));
			int type = redTypeOf(value);
			FRENewObjectFromUint32((uint32_t)type, &result);
			*/
			red_value rs = redDo((const char *)inStr);
			if(rs != NULL) {
				int type = redTypeOf(rs);

				switch(type) {
					case RED_TYPE_STRING:
						const char * outStr = redCString(rs);
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
    
    // A native context instance is created
    void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                            uint32_t* numFunctions, const FRENamedFunction** functions) {
        static FRENamedFunction extensionFunctions[] = {
            { (const uint8_t*) "Init",  NULL, Red_Init},
			{ (const uint8_t*) "redDo", NULL, Red_Do},
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
