# 📑 tink web router parser

Parse and export router information in order to:
1. transform to swagger specification
2. deploy a swagger document site

# Example
```
# input the root route as argument
$ haxe parser.hxml src/Server/api/Public > output.json
```

# TODO
- [ ] Handle tink_multipart
- [ ] Handle When multiple tink metas apply on one method
- [ ] parse non-MAP body
- [ ] Reference to Non-primitive type 
- [ ] A cli tool or a build macro?



# NOTE

A command line tool (In Build macro time? we don't need js. since it's tool for haxe)
|> Load file
|> Parse to context (Using rtti?)
|> Remaining parse logic
|> return parsed json string


- Can't mix runtime input with compile time
- I don't want pass macro flag/params when I use this tool (or this is a good idea)
- Find a way using runtime pass first?



# Swagger example
```
{
    path: {
        ...
    },
    definitions: {
        ...
    }
}
```