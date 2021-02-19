# 📑 tink web router parser (under developing)

This is a experimental project to parse and export tink web router information in order to:
1. transform to swagger specification
2. deploy a swagger document ui
3. generate client sdk

# Example
```
# input the root route as argument
$ haxe parser.hxml src/Server/api/Public > output.json
```

# NOTE
```
Start
|> Using marco to get Context (Because maybe impossible in rtti? was trying to using cli approach)
|> Collect Haxe type information from web routes root <--- This is the current state
    - Try to coverage 80% scenario first
        - ignore to complex nest type
        - ignore multipart
        - ignore body without a json format
        - ignore object type witch is dynamic key
    - Does the syntax idiom match to Haxe?
    - Dose the approach correct?
    - Nest type traverse is verbose, any better way than DRY?
    - Optional non-primitive type may refer to `TLazy`, could we reveal it?
    - Is there better union trick to prevent lots optional var in typedef?
    - More type to handle (or ignore)
        - `tink.Promise`
        - `tink.io.RealSource`
        - Some custom type
|> Transform to swagger json format
|> Integration with swagger UI | Generate client sdk from swagger json
```
