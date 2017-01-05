#include "ANERed.h"
#include <windows.h> 
#include <stdio.h> 
#include <red.h>

FREContext  AIRContext; // Used to dispatch event back to AIR

extern "C" {
    
    FREObject Red_Init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;
        
	//	redOpen();

		FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}

	FREObject Red_Hello(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;
		bool bRet = true;

	//	red_string rs = redString("hello");

		FRENewObjectFromBool((uint32_t)bRet, &result);
		return result;
	}
    
    // A native context instance is created
    void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                            uint32_t* numFunctions, const FRENamedFunction** functions) {
        static FRENamedFunction extensionFunctions[] = {
            { (const uint8_t*) "Init",  NULL, Red_Init},
			{ (const uint8_t*) "Hello", NULL, Red_Hello},
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
