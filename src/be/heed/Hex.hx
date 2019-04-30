package be.heed;

using StringTools;

abstract Hex(Int) from Int {

    @:to public inline function escaped():String return '&#x${this.hex()};';
    @:from public inline static function fromString(v:String):Hex return v.fastCodeAt(0);

}