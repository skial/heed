package be.heed;

import uhx.sys.HtmlEntity;

#if (eval || macro)
import haxe.macro.Expr;
import haxe.macro.Printer;
import uhx.sys.html.internal.Build;
#end

class Util {

    public static macro function htmlEntityMap():ExprOf<Map<String, String>> {
        var cache:Map<String, Int> = [];
        var mapExpr = [];
        var printer = new Printer();
        for (entity in HtmlEntity.all()) {
            var codepoint:Array<Int> = entity;

            if (!cache.exists('$codepoint')) {
                var codepointExpr = macro $v{ codepoint.map( i -> '$i' ).join('') };
                //var expr = macro [$a{codepointExpr}] => $v{entity};
                var expr = macro $codepointExpr => $v{entity};

                cache.set( '$codepoint', mapExpr.push( expr ) );

            } else {
                trace( entity, (entity:Array<Int>) ); // TODO check this

            }

        }

        return macro [$a{mapExpr}];
    }

}