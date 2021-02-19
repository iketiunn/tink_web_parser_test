package;

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