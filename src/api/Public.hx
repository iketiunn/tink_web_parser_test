package api;

interface Public {
    @:get("/") public function index(): String;
    @:get("/test") public function test(): String;
    @:get("/$name") public function named(name: String = "Tom"): String;
}