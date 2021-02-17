import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
import haxe.rtti.Meta;

import tink.http.Method;
import haxe.ds.Option;

class Parser {
	public static var metas = {
		var ret = [for (m in [GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE]) ':$m'.toLowerCase() => Some(m)];
		ret[':all'] = None; // TODO what to match
		ret;
	}

	// FIXME note, meta is array
	public static function getMethod(meta:haxe.macro.Type.MetaAccess) {
		for (m in metas.keys())
			if (meta.has(m))
				return m;

		if (meta.has(":all"))
			return ":all";
		if (meta.has(":sub"))
			return ":sub";

		return ':none';
	}

	public static function isEndpoint(meta:haxe.macro.Type.MetaAccess) {
		var m = getMethod(meta);
		if (m == ":sub" || m == ":none")
			return false;

		return true;
	}

	public static function isPrefix(meta:haxe.macro.Type.MetaAccess) {
		var m = getMethod(meta);
		if (m == ":sub")
			return true;

		return false;
	}

	/** Main */
	public static macro function parse(typePath:Expr):Expr {
		// Going to parse the hardcoded `dasloop.api.v2.public`
		// Make sure you put the root calss of routes
		var type = Context.getType(typePath.toString());
		var fields = type.follow().getClass().fields.get();
		var root:Node = {
			module: type.getClass().module,
			// method: null,
			prefix: '/',
			// paramters: null,
			// responses: null,
			// functionName: '',
			nodes: []
		};
		trace("----------------------");
		for (f in fields) {
			// Not only method will inside the meta! assume we only prefix it only one meta now
			trace("f.meta", Meta.getType(f));
			if (isEndpoint(f.meta)) {
				var n: Node = {
					module: type.getClass().module,
					method: getMethod(f.meta),
					prefix: "/", // empty string or values in @:get
					functionName: f.name,
					nodes: []
				};
				switch (f.type) {
					// Fot getting args and returns
					case TFun(args, ret):
						trace("args:",args);
						if (args.length > 0) {
							// Push paramters
						}
						switch (ret) {
							case TInst(t, _):
								// TODO If not primitive, parse it to typeDef
								n.responses = t.toString();
							default:
						}
					default:
				}
				root.nodes.push(n);
			}
			// Sub, yo
			if (isPrefix(f.meta)) {
				// Get the nodes of sub
				switch (f.type) {
					// Fot getting args and returns
					case TFun(args, ret):
						trace("name:",f.name);
						trace("args:",args);
						trace("return:",ret);
						switch (ret) {
							case TInst(t, params):
								// Going deep
								var tt = Context.getType(t.get().module + "." + t.get().name);
								var f = tt.follow().getClass().fields.get();
								trace(f[0]);
							default:
						}
					default:
				}
				root.nodes.push({
					module: type.getClass().module,
					// method: getMethod(f.meta),
					method: '',
					prefix: f.name, // empty string or values in @:get
					functionName: f.name,
					nodes: []
				});
				// pass the return type to parse
				// trace({
				// module: type.getClass().module,
				// 	prefix: "/" + f.name, // Will be :sub() param or the field name
				// 	leafs: f.expr(),
				// 	functionName: f.name
				// });
			}
			// etc metas, may extend it, pring waring only now
		}
		trace("----------------------");

		trace(root);

		return macro $v{root};
	}
}

typedef Node = {
	var module:String;
	var ?method:String;
	var prefix:String;
	var ?parameters:Dynamic;
	var ?responses:Dynamic; // Status code?
	var ?functionName:String;
	var nodes:Array<Node>;
	// produce
}

interface Swagger {}