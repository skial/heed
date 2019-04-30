package be.heed;

import be.Heed.decode;
import tink.unit.Assert.*;

@:assert
class HeedDecodeSpec {

    public function new() {}

    @:variant('&amp;amp;amp;', '&amp;amp;')
    @:variant('&#x26;amp;', '&amp;')
    @:variant('a&foololthisdoesntexist;b', 'a&foololthisdoesntexist;b')
    @:variant('foo &lolwat; bar', 'foo &lolwat; bar')
    @:variant('&notin; &noti &notin &copy123', '\u2209 \u{00AC}i \u{00AC}in \u{00A9}123')
    @:variant('&amp;xxx; &amp;xxx &ampthorn; &ampthorn &ampcurren;t &ampcurrent', '&xxx; &xxx &thorn; &thorn &curren;t &current')
    @:variant('a&#xD834;&#xDF06;b&#55348;&#57094;c a&#x0;b&#0;c', 'a\uFFFD\u{FFFD}b\uFFFD\u{FFFD}c a\u{FFFD}b\u{FFFD}c')
    @:variant('a&#x9999999999999999;b', 'a\u{FFFD}b')
    @:variant('foo&ampbar', 'foo&bar')
    @:variant('foo&ampbar', 'foo&ampbar', true)
    @:variant('foo&amp;bar', 'foo&bar', true)
    @:variant('foo&amp=', 'foo&amp=', true)
    @:variant('foo&amp', 'foo&', true)
    @:variant('I\'m &notit; I tell you', 'I\'m &notit; I tell you', true)
    @:variant('I\'m &notin; I tell you', 'I\'m \u2209 I tell you', false, true)
    @:variant('&#x8D;', '\u008D')
    @:variant('&#x94;', '\u201D')
    @:variant('&#xZ', '&#xZ', false, false)
    @:variant('&#00', '\uFFFD')
    @:variant('&#0128;', '\u20AC')
    public function testDecode(input:String, output:String, isAttribute = false, strict = false) {
        return assert( decode(input, isAttribute, strict) == output );
    }

}