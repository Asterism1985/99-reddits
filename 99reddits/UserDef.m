//
//  UserDef.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDef.h"

NSString *defaultSubRedditsNameArray[] = {
    @"pics", 
    @"funny",
    @"gaming",
    @"aww",
    @"GIFs",
    @"AdviceAnimals",
    @"fffffffuuuuuuuuuuuu",
    @"lolcats",
    @"iWallPaper",
    @"MoviePosterPorn",
    @"99reddits" 
};

NSString *defaultSubRedditsURLArray[] = {
    @"http://www.reddit.com/r/pics/.json?limit=50", 
    @"http://www.reddit.com/r/funny/.json?limit=50",
    @"http://www.reddit.com/r/gaming/.json?limit=50",
    @"http://www.reddit.com/r/aww/.json?limit=50",
    @"http://www.reddit.com/r/GIFs/.json?limit=50",
    @"http://www.reddit.com/r/AdviceAnimals/.json?limit=50",
    @"http://www.reddit.com/r/fffffffuuuuuuuuuuuu/.json?limit=50",
    @"http://www.reddit.com/r/lolcats/.json?limit=50",
    @"http://www.reddit.com/r/iWallPaper/.json?limit=50",
    @"http://www.reddit.com/r/MoviePosterPorn/.json?limit=50",
    @"http://www.reddit.com/r/99reddits/.json?limit=50"
};

NSString *htmlStrings[] = {
	@"&ndash;",		@"&#8211;",		@"&mdash;",		@"&#8212;",		@"&iexcl;",		@"&#161;",		@"&iquest;",	@"&#191;",		@"&quot;",		@"&#34;",
	@"&ldquo;",		@"&#8220;",		@"&rdquo;",		@"&#8221;",		@"&#39;",		@"&lsquo;",		@"&#8216;",		@"&rsquo;",		@"&#8217;",		@"&laquo;",
	@"&#171;",		@"&raquo;",		@"&#187;",		@"&nbsp;",		@"&#160;",		@"&amp;",		@"&#38;",		@"&cent;",		@"&#162;",		@"&copy;",
	@"&#169;",		@"&divide;",	@"&#247;",		@"&gt;",		@"&#62;",		@"&lt;",		@"&#60;",		@"&micro;",		@"&#181;",		@"&middot;",
	@"&#183;",		@"&para;",		@"&#182;",		@"&plusmn;",	@"&#177;",		@"&euro;",		@"&#8364;",		@"&pound;",		@"&#163;",		@"&reg;",
	@"&#174;",		@"&sect;",		@"&#167;",		@"&trade;",		@"&#153;",		@"&yen;",		@"&#165;",		@"&aacute;",	@"&#225;",		@"&Aacute;",
	@"&#193;",		@"&agrave;",	@"&#224;",		@"&Agrave;",	@"&#192;",		@"&acirc;",		@"&#226;",		@"&Acirc;",		@"&#194;",		@"&aring;",
	@"&#229;",		@"&Aring;",		@"&#197;",		@"&atilde;",	@"&#227;",		@"&Atilde;",	@"&#195;",		@"&auml;",		@"&#228;",		@"&Auml;",
	@"&#196;",		@"&aelig;",		@"&#230;",		@"&AElig;",		@"&#198;",		@"&ccedil;",	@"&#231;",		@"&Ccedil;",	@"&#199;",		@"&eacute;",
	@"&#233;",		@"&Eacute;",	@"&#201;",		@"&egrave;",	@"&#232;",		@"&Egrave;",	@"&#200;",		@"&ecirc;",		@"&#234;",		@"&Ecirc;",
	@"&#202;",		@"&euml;",		@"&#235;",		@"&Euml;",		@"&#203;",		@"&iacute;",	@"&#237;",		@"&Iacute;",	@"&#205;",		@"&igrave;",
	@"&#236;",		@"&Igrave;",	@"&#204;",		@"&icirc;",		@"&#238;",		@"&Icirc;",		@"&#206;",		@"&iuml;",		@"&#239;",		@"&Iuml;",
	@"&#207;",		@"&ntilde;",	@"&#241;",		@"&Ntilde;",	@"&#209;",		@"&oacute;",	@"&#243;",		@"&Oacute;",	@"&#211;",		@"&ograve;",
	@"&#242;",		@"&Ograve;",	@"&#210;",		@"&ocirc;",		@"&#244;",		@"&Ocirc;",		@"&#212;",		@"&oslash;",	@"&#248;",		@"&Oslash;",
	@"&#216;",		@"&otilde;",	@"&#245;",		@"&Otilde;",	@"&#213;",		@"&ouml;",		@"&#246;",		@"&Ouml;",		@"&#214;",		@"&szlig;",
	@"&#223;",		@"&uacute;",	@"&#250;",		@"&Uacute;",	@"&#218;",		@"&ugrave;",	@"&#249;",		@"&Ugrave;",	@"&#217;",		@"&ucirc;",
	@"&#251;",		@"&Ucirc;",		@"&#219;",		@"&uuml;",		@"&#252;",		@"&Uuml;",		@"&#220;",		@"&yuml;",		@"&#255;",		@"&#180;",
	@"&#96;"
};

NSString *normalStrings[] = {
	@"–",	@"–",	@"—",	@"—",	@"¡",	@"¡",	@"¿",	@"¿",	@"\"",	@"\"",
	@"“",	@"“",	@"”",	@"”",	@"'",	@"‘",	@"‘",	@"’",	@"’",	@"«",
	@"«",	@"»",	@"»",	@" ",	@" ",	@"&",	@"&",	@"¢",	@"¢",	@"©",
	@"©",	@"÷",	@"÷",	@">",	@">",	@"<",	@"<",	@"µ",	@"µ",	@"·",
	@"·",	@"¶",	@"¶",	@"±",	@"±",	@"€",	@"€",	@"£",	@"£",	@"®",
	@"®",	@"§",	@"§",	@"™",	@"™",	@"¥",	@"¥",	@"á",	@"á",	@"Á",
	@"Á",	@"à",	@"à",	@"À",	@"À",	@"â",	@"â",	@"Â",	@"Â",	@"å",
	@"å",	@"Å",	@"Å",	@"ã",	@"ã",	@"Ã",	@"Ã",	@"ä",	@"ä",	@"Ä",
	@"Ä",	@"æ",	@"æ",	@"Æ",	@"Æ",	@"ç",	@"ç",	@"Ç",	@"Ç",	@"é",
	@"é",	@"É",	@"É",	@"è",	@"è",	@"È",	@"È",	@"ê",	@"ê",	@"Ê",
	@"Ê",	@"ë",	@"ë",	@"Ë",	@"Ë",	@"í",	@"í",	@"Í",	@"Í",	@"ì",
	@"ì",	@"Ì",	@"Ì",	@"î",	@"î",	@"Î",	@"Î",	@"ï",	@"ï",	@"Ï",
	@"Ï",	@"ñ",	@"ñ",	@"Ñ",	@"Ñ",	@"ó",	@"ó",	@"Ó",	@"Ó",	@"ò",
	@"ò",	@"Ò",	@"Ò",	@"ô",	@"ô",	@"Ô",	@"Ô",	@"ø",	@"ø",	@"Ø",
	@"Ø",	@"õ",	@"õ",	@"Õ",	@"Õ",	@"ö",	@"ö",	@"Ö",	@"Ö",	@"ß",
	@"ß",	@"ú",	@"ú",	@"Ú",	@"Ú",	@"ù",	@"ù",	@"Ù",	@"Ù",	@"û",
	@"û",	@"Û",	@"Û",	@"ü",	@"ü",	@"Ü",	@"Ü",	@"ÿ",	@"ÿ",	@"´",
	@"`"
};

// Facebook
NSString *kAppId = @"253475838035936";

