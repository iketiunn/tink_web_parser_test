package server.api;

interface Public {
    @:get("/") public function index(): String;
    @:get("/test") public function test(): String;
    @:get("/test/$id") public function testId(id: String): String;

    @:sub public function api(): server.api.Api;
}
