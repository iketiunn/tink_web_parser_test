# 📑 tink web router parser

Parse and export router information in order to:
1. transform to swagger specification
2. deploy a swagger document site

# Example
```
# input the root route as argument
$ haxe parser.hxml src/api/Public > export.json
```

# TODO
- [] Handle tink_multipart
- [] Handle When multiple tink metas apply on one method
- [] parse non-MAP body
- [] Reference Non-primitive type 
