import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.Option;
using haxe.macro.Tools;

import tink.http.Method;

class Parser {
	public static var metas = {
		var ret = [for (m in [GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE]) ':$m'.toLowerCase() => Some(m)];
		ret[':all'] = None; // TODO what to match
		ret;
	}

	// FIXME note, meta is array
	public static function getMethod(meta:haxe.macro.Type.MetaAccess) {
		for (m in metas.keys()) {
			if (meta.has(m)) {
				return m;
			}
		}

		if (meta.has(":all"))
			return ":all";
		if (meta.has(":sub"))
			return ":sub";

		return ':none';
	}

	// Get meta name expect :none
	public static function getMethodMeta(meta:haxe.macro.Type.MetaAccess) {
		var _metas: Array<MetadataEntry> = [];
		for (m in metas.keys()) {
			if (meta.has(m)) {
				_metas = _metas.concat(meta.extract(m));
			}
		}
				
		if (meta.has(":all"))
			_metas = _metas.concat(meta.extract(':all'));
		if (meta.has(":sub"))
			_metas = _metas.concat(meta.extract(":sub"));

		if (_metas.length > 1) {
			trace('Waring: Mutitple metas is not support for now!');
		}

		return _metas;
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

	/** Main logic goes here **/
	public static function _parse(cl:haxe.macro.Type.ClassType): Node {
		var fields = cl.fields.get();
		var root:Node = {
			module: cl.module,
			// method: null,
			prefix: '/',
			// parameters: [],
			// responses: null,
			// functionName: '',
			nodes: []
		};
		for (f in fields) {
			// Get Method meta = not :none
			var methodMetas = getMethodMeta(f.meta);
			// Only get the first params in the first meta as prefix value
			var metaValue =  methodMetas[0].params.length > 0 ? methodMetas[0].params[0].getValue() : '';
			if (isEndpoint(f.meta)) {
				var n: Node = {
					module: cl.module,
					method: getMethod(f.meta),
					prefix: metaValue, // empty str ing or values in @:get
					parameters: [],
					functionName: f.name,
				};
				switch (f.type) {
					case TFun(args, ret):
						/** Parse parameters **/
						for (a in args) {
							switch (a.t) {
								case TType(t, _params):
									n.parameters.push({
										type: 'ref',
										name: a.name,
										ref:t.get().name
									});
								case TAbstract(t, _params):
									n.parameters.push({
										type: t.get().name.toLowerCase(),
										name: a.name,
									});
								case TAnonymous(aa):
									// Could be trans to json stringify
									var object: Data = {
										type: 'object',
										name: a.name,
										properties: []
									};
									for (ff in aa.get().fields) {
										// trace(field.name);
										// trace(ff.name);
										switch (ff.type) {
											case TInst(tt, _params):
												object.properties.push({
													type: tt.get().name.toLowerCase(),
													name: ff.name
												});
											default:
										}
									}
									n.parameters.push(object);
								case TInst(t, params): {
									n.parameters.push({
										type: t.get().name.toLowerCase(),
										name: a.name
									});
								}
								default:
									trace(a);
									n.parameters.push({
										type: "UNKNOWN"
									});
							}
						}
						/** Parse Responses **/
						switch (ret) {
							case TType(t, _params):
								n.responses = [
									{
										statusCode: 200,
										description: '',
										schema: {
											type: "ref",
											ref: t.toString()
										}
									}
								];
							case TInst(t, params):
								var data: Data = {
									type: 'None'
								};
								// Handle different type, some of them might have params
								if (t.get().name == 'Array') {
									data.type = 'array';
									// Assume that array only have one type now, discourage multiple types in one array 
									switch (params[0]) {
										case TType(t, params):
											data.items = {
												type: t.get().name.toLowerCase()
											};
										default:
									}
								} else if (t.get().name == 'String') {
									data.type = 'string';
								} else {
									// Not handling this type yet, throw
									trace(f);
									throw 'Invalid type:' + t.get().name;
								}
								n.responses = [
									{
										statusCode: 200,
										description: '',
										schema: data
									}
								];
							default:
						}
					default:
				}
				root.nodes.push(n);
			}
			var nodes: Array<Node> = [];
			if (isPrefix(f.meta)) {
				// Get the nodes of sub
				switch (f.type) {
					case TFun(args, ret): // Just need to handle function
						switch (ret) {
							case TInst(t, params):
								// Going deep
								nodes = _parse(t.get()).nodes;
							default:
						}
					default:
				}
				root.nodes.push({
					module: cl.module,
					prefix: metaValue == '' ? '/' + f.name : metaValue, // empty string or values in @:get
					functionName: f.name,
					nodes: nodes
				});
			}
		}

		return root;
	}

	/** Main */
	public static macro function parse(typePath:Expr):haxe.macro.Expr.ExprOf<String> {
		// Make sure you put the root class of routes
		var type = Context.getType(typePath.toString()); // TODO: Why this step, take from example
		var cl = type.follow().getClass();

		// Should be only one level
		var root = _parse(cl);
		var ret = haxe.Json.stringify(root, null ,' ');
		// Sys.println(
		// 	haxe.Json.stringify(root, null ,' ')
		// );

		return macro {};
	}
}

typedef Node = {
	var module:String;
	var ?method:String;
	var prefix:String;
	var ?parameters:Array<Data>;
	var ?responses:Array<Response>; // By default, it treat as 200
	var ?functionName:String;
	var ?nodes:Array<Node>;
}


// Union type example
// Data String
// typedef DataString = {
// 	var type: string;
// }
// Data Object
// typedef DataObject = {
// 	var type = "object";
// 	var properties = Data;
// }
// // ...

typedef Data = {
	var type: String;
	var ?name: String; // When it's parameters
	var ?description: String;
	var ?format: String;
	var ?properties: Array<Data>; // For object or nest object
	var ?items: Data; // For array
	var ?ref: String; // For reference
}

typedef Response = {
	var statusCode: Int;
	var description: String;
	var schema: Data;
}

interface Swagger {}
