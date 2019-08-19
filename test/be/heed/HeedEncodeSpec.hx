package be.heed;

import be.Heed.encode;
import tink.unit.Assert.*;

#if js
#if nodejs 
@:jsRequire('../he') 
#else
@:native('he')
#end
extern class He {
    public static function encode(text:String, ?options:{}):String;
    public static function decode(text:String, ?options:{}):String;

}
#end

@:asserts
class HeedEncodeSpec {

    public function new() {}

    @:variant('\'"<>&', '&#x27;&#x22;&#x3C;&#x3E;&#x26;')
    @:variant('\'"<>&', '&#39;&#34;&#60;&#62;&#38;', false, false, true)
    @:variant('a\tb', '&#x61;&#x9;&#x62;', true)
    @:variant('a\tb', '&#97;&#9;&#98;', true, false, true)
    @:variant('a\tb', '&#x61;&Tab;&#x62;', true, true)
    @:variant('a&b123;+\u00A9>\u20D2<\u20D2\nfja', '&#x61;&#x26;&#x62;&#x31;&#x32;&#x33;&#x3B;&#x2B;&#xA9;&#x3E;&#x20D2;&#x3C;&#x20D2;&#xA;&#x66;&#x6A;&#x61;', true)
    @:variant('a&b123;+\u00A9>\u20D2<\u20D2\nfja', '&#x61;&amp;&#x62;&#x31;&#x32;&#x33;&semi;&plus;&copy;&nvgt;&nvlt;&NewLine;&fjlig;&#x61;', true, true)
    #if !hl @:variant('\x00\u0089', '\x00\u0089') #end // NUL character ends strings.
    @:variant('a<b', '&#x61;&#x3C;&#x62;', true, false, false, true)
    @:variant('a<b', '&#97;&#60;&#98;', true, false, true, true)
    @:variant('a<b', '&#97;&#60;&#98;', true, false, true, true)
    @:variant('a<\u00E4>', 'a<&auml;>', false, true, true, true)
    @:variant('a<\u223E>', 'a<&ac;>', false, true, false, true)
    @:variant('\u00E4\u00F6\u00FC\u00C4\u00D6\u00DC', '&#228;&#246;&#252;&#196;&#214;&#220;', false, false, true)
    @:variant('\u00E4\u00F6\u00FC\u00C4\u00D6\u00DC', '&auml;&ouml;&uuml;&Auml;&Ouml;&Uuml;', false, true, true)
    public function testEncode(value:String, output:String, everything:Bool = false, named:Bool = false, decimal:Bool = false, unsafe:Bool = false) {
        asserts.assert( encode(value, everything, named, decimal, unsafe) == output );
        return asserts.done();
    }

}