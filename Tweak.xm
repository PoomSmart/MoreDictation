#import <substrate.h>
#import "../PS.h"

// iOS 7.0- : NSArray *AFPreferencesSupportedLanguages()
// iOS 7.1+ : NSArray *AFPreferencesSupportedDictationLanguages()
// iOS 7.1+ : NSArray *_AFPreferencesBuiltInLanguagesDictationSupplement()

BOOL doNotAddYet = NO;

NSArray *moreSupportedLanguages()
{
	return @[	@"nl-NL", // Dutch - The Netherlands
				@"sv-SE", // Swedish - Sweden
				@"pt-BR", // Portuguese - Brazil
				@"pt-PT", // Portuguese - Portugal
				@"hu-HU", // Hungarian - Hungary
				@"pl-PL", // Polish - Poland
				@"nb-NO", // Norwegian (Bokmål) - Norway
				@"fi-FI", // Finnish - Finland
				@"da-DK", // Danish - Denmark
				@"ru-RU", // Russian - Russia
				@"el-GR", // Greek - Greece
				@"ca-ES", // Catalan - Spain
				@"hr-HR", // Croatian - Croatia
				@"cs-CZ", // Czech - Czech Republic
				@"id-ID", // Indonesian - Indonesia
				@"ms-MY", // Malay - Malaysia
				@"ro-RO", // Romanian - Romania
				@"sk-SK", // Slovak - Slovakia
				@"th-TH", // Thai - Thailand
				@"tr-TR", // Turkish - Turkey
				@"uk-UA", // Ukrainian - Ukraine
				@"vi-VN", // Vietnamese - Vietnam
				
				@"he-IL", // Hebrew - Israel
	];
}

NSArray *(*PSPreferencesSupportedDictationLanguages)();
NSArray *(*original_PSPreferencesSupportedDictationLanguages)();
NSArray *hax_PSPreferencesSupportedDictationLanguages()
{
	NSMutableArray *array = [original_PSPreferencesSupportedDictationLanguages() mutableCopy];
	if (doNotAddYet)
		return array;
	for (NSString *language in moreSupportedLanguages()) {
		if (![array containsObject:language])
			[array addObject:language];
	}
	return array;
}

%group preiOS71

%hook AssistantController

// This method will return all languages from AFPreferencesSupportedLanguages() function.
// But the issue is some languages are not supported by Siri, if the function is hooked.
// Adding those unsupported is not a good way, as user will not be able to use it.
// So we just prevent the issue here, by temporary disallowing languages addition.
+ (id)assistantLanguageTitlesDictionary
{
	doNotAddYet = YES;
	id support = %orig;
	doNotAddYet = NO;
	return support;
}

%end

%end

%ctor
{
	if (!isiOS71Up) {
		if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
			dlopen("/System/Library/PreferenceBundles/Assistant.bundle/Assistant", RTLD_LAZY);
			%init(preiOS71);
		}
	}
	#define ASSISTANT "/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices"
	void *assistant = dlopen(ASSISTANT, RTLD_LAZY);
	if (assistant != NULL) {
		MSImageRef ref = MSGetImageByName(ASSISTANT);
		const char *function = isiOS71Up ? "__AFPreferencesBuiltInLanguagesDictationSupplement" : "_AFPreferencesSupportedLanguages";
		PSPreferencesSupportedDictationLanguages = (NSArray *(*)())MSFindSymbol(ref, function);
		MSHookFunction((void *)PSPreferencesSupportedDictationLanguages, (void *)hax_PSPreferencesSupportedDictationLanguages, (void **)&original_PSPreferencesSupportedDictationLanguages);
	}
}