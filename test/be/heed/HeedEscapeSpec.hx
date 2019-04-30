package be.heed;

import be.Heed.escape;
import be.Heed.decode as unescape;
import tink.unit.Assert.*;

@:assert
class HeedEscapeSpec {

    public function new() {}

    @:variant('<img src=\'x\' onerror="prompt(1)"><script>alert(1)</script><img src="x` `<script>alert(1)</script>"` `>', '&lt;img src=&#x27;x&#x27; onerror=&quot;prompt(1)&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;&lt;img src=&quot;x&#x60; &#x60;&lt;script&gt;alert(1)&lt;/script&gt;&quot;&#x60; &#x60;&gt;')
    public function testEscape(input:String, output:String) {
        return assert( escape(input) == output );
    }

    @:variant('&lt;img src=&#x27;x&#x27; onerror=&quot;prompt(1)&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;&lt;img src=&quot;x&#x60; &#x60;&lt;script&gt;alert(1)&lt;/script&gt;&quot;&#x60; &#x60;&gt;', '<img src=\'x\' onerror="prompt(1)"><script>alert(1)</script><img src="x` `<script>alert(1)</script>"` `>')
    public function testUnescape(input:String, output:String) {
        return assert( unescape(input) == output );
    }

}