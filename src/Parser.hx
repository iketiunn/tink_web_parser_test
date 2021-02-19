package;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.Option;

using haxe.macro.Tools;

import tink.http.Method;

class Parser {
	static var metas = {
		var ret = [
			for (m in [GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE])
				':$m'.toLowerCase() => Some(m)
		];
		ret[':all'] = None; // TODO what to match
		ret;
	}

	// FIXME note, meta is array
	static function getMethod(meta:haxe.macro.Type.MetaAccess) {
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
	static function getMethodMeta(meta:haxe.macro.Type.MetaAccess) {
		var _metas:Array<MetadataEntry> = [];
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
			trace('Waring: Multiple metas is not support for now!');
		}

		return _metas;
	}

	static function isEndpoint(meta:haxe.macro.Type.MetaAccess) {
		var m = getMethod(meta);
		if (m == ":sub" || m == ":none")
			return false;

		return true;
	}

	static function isPrefix(meta:haxe.macro.Type.MetaAccess) {
		var m = getMethod(meta);
		if (m == ":sub")
			return true;

		return false;
	}
	static var defs: Array<Def> = [];

	// TODO, how far should a parser go deep into?
	static function parseAbstract(name: String, t: haxe.macro.Type.Ref<haxe.macro.Type.AbstractType>, params:Array<haxe.macro.Type>) {
		var def: Data = {
			name: name,
			type: 'Unknown'
		};
		var typeName = t.get().name;
		if (typeName == 'Null') {
			// Parse params
			switch (params[0]) {
				case TInst(t, _params):
					// TODO: Maybe array, maybe other	
					// if (t.get().name == 'Array') {
					// 	var p: Data = {
					// 		type: 'Array',
					// 		name: name,
					// 		required: false
					// 	}
					// 	// Parse params
					// 	switch (params[0]) {
					// 		case TInst(_t, pp):
					// 			switch (pp[0]) {
					// 				case TType(t, params):
					// 					p.items = {
					// 						type: t.toString()
					// 					};
					// 				default:
					// 			}
					// 			// May nested!
					// 		default:
					// 	}
					// 	// properties.push(p);

					// 	trace(p);
					// } else {
					// 	return {
					// 		type: t.toString(),
					// 		name: name,
					// 		required: false
					// 	};
					// }
					
					// TODO: handle the different types

					def.type = t.toString();
					def.required = false; 
				default:
			}
		}

		return def;
	}
	static function parseAnonymousAbstract(a:haxe.macro.Type.Ref<haxe.macro.Type.AnonType>) {
		var properties:Array<Data> = [];
		for (f in a.get().fields) {
			// trace(t.get().name, f.name, f.type);
			switch (f.type) {
				case TLazy(_f):
					// It's a optional typedef, but showed as TLazy
					// Without optional, it will be TType(...)
					properties.push({
						type: 'Unknown',
						name: f.name,
						description: 'TODO'
					});
				case TAbstract(t, params):
					// Might a Null
					var typeName = t.get().name;
					if (typeName == 'Null') {
						// Parse params
						switch (params[0]) {
							case TInst(t, _params):
								// Maybe array, maybe other	
								if (t.get().name == 'Array') {
									var p: Data = {
										type: 'Array',
										name: f.name,
										required: false
									}
									// Parse params
									switch (params[0]) {
										case TInst(_t, pp):
											switch (pp[0]) {
												case TType(t, params):
													p.items = {
														type: t.toString()
													};
												default:
											}
											// May nested!
										default:
									}
									properties.push(p);
								} else {
									properties.push({
										type: t.toString(),
										name: f.name,
										required: false
									});
								}
							default:
						}
					}
				case TInst(t, params):
					var typeName = t.get().name;
					if (typeName == 'Array') {
						var p: Data = {
							type: 'Array',
							name: f.name,
						}
						// Parse params
						switch (params[0]) {
							case TInst(t, _params):
								p.items = {
									type: t.toString()
								}
							default:
						}
						properties.push(p);
					} else if (typeName == 'String') {
						properties.push({
							type: typeName,
							name: f.name
						});
					}
				default:
			}
		}

		return properties;
	}

	static function parseDefs(t: haxe.macro.Type.Ref<haxe.macro.Type.DefType>) {
		var def: Data = {
			name: t.toString(),
			type: 'Object',
			properties: []
		};
		// trace(t.get().name, t.get().type);
		switch (t.get().type) {
			/** Is a typedef type **/
			case TAbstract(tt, params):
				def = parseAbstract(t.toString(), tt, params);
			/** Is a typedef structure **/
			case TAnonymous(a):
				def.properties = parseAnonymousAbstract(a);
			default:
		}

		defs.push(def);
	}

	/** Main logic goes here **/
	// static function _parse(cl:haxe.macro.Type.ClassType):Node {
	static function _parse(cl:haxe.macro.Type.ClassType): Node {
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
			var metaValue = methodMetas[0].params.length > 0 ? methodMetas[0].params[0].getValue() : '';
			if (isEndpoint(f.meta)) {
				var n:Node = {
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
										ref: t.toString()
									});
									/** Parse Def **/
									parseDefs(t);
								case TAbstract(t, _params):
									n.parameters.push({
										type: t.toString(),
										name: a.name,
									});
								case TAnonymous(aa):
									// Could be trans to json stringify
									var object:Data = {
										type: 'Object',
										name: a.name,
										properties: []
									};
									for (ff in aa.get().fields) {
										// trace(field.name);
										// trace(ff.name);
										switch (ff.type) {
											case TInst(tt, _params):
												object.properties.push({
													type: tt.toString(),
													name: ff.name
												});
											default:
										}
									}
									n.parameters.push(object);
								case TInst(t, params): {
										n.parameters.push({
											type: t.toString(),
											name: a.name
										});
									}
								default:
									trace(a);
									n.parameters.push({
										type: "Unknown"
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
								/** Parse Def **/
								parseDefs(t);
							case TInst(t, params):
								var data:Data = {
									type: 'None'
								};
								// Handle different type, some of them might have params
								if (t.get().name == 'Array') {
									data.type = 'Array';
									// Assume that array only have one type now, discourage multiple types in one array
									switch (params[0]) {
										case TType(t, _params):
											data.items = {
												type: t.toString()
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
			var nodes:Array<Node> = [];
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
		// Using context to trans file path to class path
		// Make sure you put the root class of routes
		var type = Context.getType(typePath.toString()); // TODO: Why this step, take from example
		var cl = type.follow().getClass();

		// Should be only one level
		// _parse(cl);
		var root = _parse(cl);
		// trace(root);
		var ret = {
			routes: root,
			defs: defs
		};
		Sys.println(haxe.Json.stringify(ret, null, ' '));
		// Sys.println(haxe.Json.stringify(root, null, ' '));

		return macro {};
	}
}

// Swagger defs
typedef Swagger = {
	var swagger:String;
	var info:SwaggerInfo;
	var host:String;
	var basePath:String;
	var tags:Array<SwaggerTag>;
	var schemes:Array<String>;
	
	var paths:Dynamic;
	var definitions:Dynamic;
};

typedef SwaggerInfo = {
	var description:String;
	var version:String;
	var title:String;
	var termsOfService:String;
	var contact:{
		email:String
	};
	var license:{
		name:String, url:String
	};
};

typedef SwaggerTag = {
	var name:String;
	var description:String;
	var externalDocs:{
		description:String, url:String
	};
};

/** Custom parser defs, intermediate for swagger def **/
typedef Node = {
	var module:String;
	var ?method:String;
	var prefix:String;
	var ?parameters:Array<Data>;
	var ?responses:Array<Response>; // By default, it treat as 200
	var ?functionName:String;
	var ?nodes:Array<Node>;
}

typedef Data = {
	var type:String;
	var ?name:String; // When it's parameters
	var ?required: Bool; // This may not nullable
	var ?description:String;
	var ?format:String;
	var ?properties:Array<Data>; // For object or nest object
	var ?items:Data; // For array
	var ?ref:String; // For reference
}

typedef Response = {
	var statusCode:Int;
	var description:String;
	var schema:Data;
}

typedef Def = Dynamic

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
