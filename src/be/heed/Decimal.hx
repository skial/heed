package be.heed;

using StringTools;

abstract Decimal(Int) from Int {

    @:to public inline function escaped():String return '&#${this};';
    @:from public inline static function fromString(v:String):Decimal return v.fastCodeAt(0);

}