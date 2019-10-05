package be.heed.macros;

#if (eval || macro)
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
import uhx.sys.HtmlEntity;
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.CodeUtil;
import rxpattern.internal.RangeUtil;
import be.heed.macros.Util.Paths.*;
import be.heed.macros.Util.Errors.*;

using haxe.Json;
using sys.io.File;
using StringTools;

enum abstract Defines(String) {

    public var Php = 'php';
    public var Save = 'save';
    public var DryRun = 'dryrun';
    public var Debug = 'debug';
    public var Display = 'display';
    public var DisplayDetails = 'display-details';

    @:to public inline function defined():Bool {
        return Context.defined(this);
    }

    @:op(!A) inline function not():Bool {
        return !defined();
    }

    @:op(A || B) inline function or(that:Defines):Bool {
        return defined() || that.defined();
    }

    @:op(A && B) inline function and(that:Defines):Bool {
        return defined() && that.defined();
    }

}

abstract Paths(String) from String to String {

    public static var Cwd:Paths = Sys.getCwd();
    public static var HeDir:Paths = '$Cwd/he/';
    public static var HeData:Paths = '$HeDir/data/';
    public static var EncodeLonePoints:Paths = '$HeData/encode-lone-code-points.json';
    public static var EncodePairedSymbols:Paths = '$HeData/encode-paired-symbols.json';
    public static var DecodeCodePointsOverrides:Paths = '$HeData/decode-code-points-overrides.json';

    @:to public inline function exists():Bool {
        return FileSystem.exists(this);
    }

    @:op(!A) inline function not():Bool {
        return !exists();
    }

}

abstract Errors(String) to String {
    public static var NoSubmodule = 'The directory ${Paths.HeDir} does not exist. Add `https://github.com/mathiasbynens/he/` as a submodule or local directory.';
}
#end

class Util {

    #if (eval || macro)
    private static function joinStrings(a:Null<String>, b:Null<String>):String {
        if (a != null && b != null) {
            return a + '|' + b;
        }
        return a + b;
    }
    #end

    public static macro function get_regexEncodeNonAscii():ExprOf<EReg> {
        var pos = Context.currentPos();

        if (!HeDir) Context.error(Errors.NoSubmodule, pos);

        var loneCodePointsRaw:Array<Int> = EncodeLonePoints.getContent().parse();
        var loneCodePoints:Ranges = new Ranges([]);
        for (c in loneCodePointsRaw) loneCodePoints.add(c);
        var arrayEncodeMultipleSymbols:Array<String> = EncodePairedSymbols.getContent().parse();
        var arrayEncodeMultipleSymbolsAscii:Array<String> = arrayEncodeMultipleSymbols
            .filter( s -> new EReg('^[\\x00-\\x7F]+$', '').match(s) );
        
        var rs = loneCodePoints.copy();
        rs.remove( new Range(0x7F + 1, 0x10FFFF) );
        var encodeSingleSymbolsAscii = RangeUtil.printRanges( rs, false ).get();

        rs = loneCodePoints.copy();
        rs.remove( new Range(0x00, 0x7F) );
        var encodeSingleSymbolsNonAscii = RangeUtil.printRanges( rs, false ).get();

        var encodeMultipleSymbolsAscii = arrayEncodeMultipleSymbolsAscii.join('|');
        var array = arrayEncodeMultipleSymbols
            .copy()
            .map( s -> {
                var r = '';
                for (c in unifill.Unifill.uIterator(s)) {
                    r += CodeUtil.printCode(c);
                }
                r;
            } );
        for (value in arrayEncodeMultipleSymbolsAscii) array.remove( value );
        var encodeMultipleSymbolsNonAscii = array.join('|');

        var regexEncodeAscii = joinStrings(
            encodeMultipleSymbolsAscii,
            encodeSingleSymbolsAscii
        );

        var regexEncodeNonAscii = joinStrings(
            encodeMultipleSymbolsNonAscii,
	        encodeSingleSymbolsNonAscii
        );

        var opt = 'ug';
        var regex = regexEncodeNonAscii;
        
        return macro @:pos(pos) new rxpattern.internal.EReg($v{regex}, $v{opt});
    }

    public static macro function get_regexAstralSymbol():ExprOf<EReg> {
        var pos = Context.currentPos();
        var rs = new Ranges([new Range(0x010000, 0x10FFFF)]);
        var str = RangeUtil.printRanges(rs, false).get();
        var opt = 'ug';
        return macro @:pos(pos) new rxpattern.internal.EReg($v{str}, $v{opt});
    }

    public static macro function get_regexBmpWhitelist():ExprOf<EReg> {
        var pos = Context.currentPos();
        var rs = new Ranges([new Range(0x0, 0xFFFF)]);
        rs.remove('\r'.code);
        rs.remove('\n'.code);
        rs.remove(new Range(0x20, 0x7E));
        if (!DecodeCodePointsOverrides) Context.error('Cannot find ${DecodeCodePointsOverrides}', pos);
        var values:Array<Int> = haxe.Json.parse(DecodeCodePointsOverrides.getContent());
        for (v in values) rs.remove( v );
        var str = RangeUtil.printRanges(rs, false).get();
        var opt = 'ug';
        return macro @:pos(pos) new rxpattern.internal.EReg($v{str}, $v{opt});
    }

    public static macro function entityMap():ExprOf<Map<String, String>> {
        var cache:Map<String, Int> = [];
        var mapExpr = [];
        
        for (entity in HtmlEntity.all()) {
            var codepoint:Array<Int> = entity;

            if (!cache.exists('$codepoint')) {
                var codepointExpr = macro $v{ codepoint.map( i -> '$i' ).join('') };
                var expr = macro $codepointExpr => $v{entity};

                cache.set( '$codepoint', mapExpr.push( expr ) );

            } else {
                //trace( entity, (entity:Array<Int>) ); // TODO check this

            }

        }

        return macro [$a{mapExpr}];
    }


}