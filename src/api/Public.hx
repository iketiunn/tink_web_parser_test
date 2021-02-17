package api;

interface Public {
    @:get("/test") function test(): String;
}