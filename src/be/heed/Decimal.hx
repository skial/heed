package be.heed;

using StringTools;

abstract Decimal(Int) from Int {

    @:to public inline function escaped():String return '&#${this};';

}