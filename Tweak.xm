#import <substrate.h>
#import "../PS.h"

// iOS 7.0- : NSArray *AFPreferencesSupportedLanguages()
// iOS 7.1+ : NSArray *AFPreferencesSupportedDictationLanguages()

NSArray *moreSupportedLanguages()
{
	return @[	@"en-IN", // Indian English (maybe Arabic - Saudi Arabia)
				@"nl-NL", // Dutch - The Netherlands
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
	for (NSString *language in moreSupportedLanguages()) {
		if (![array containsObject:language])
			[array addObject:language];
	}
	return array;
}

%ctor
{
	#define ASSISTANT "/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices"
	void *assistant = dlopen(ASSISTANT, RTLD_LAZY);
	if (assistant != NULL) {
		MSImageRef ref = MSGetImageByName(ASSISTANT);
		const char *function = isiOS71Up ? "_AFPreferencesSupportedDictationLanguages" : "_AFPreferencesSupportedLanguages";
		PSPreferencesSupportedDictationLanguages = (NSArray *(*)())MSFindSymbol(ref, function);
		MSHookFunction((void *)PSPreferencesSupportedDictationLanguages, (void *)hax_PSPreferencesSupportedDictationLanguages, (void **)&original_PSPreferencesSupportedDictationLanguages);
	}
}