package api;

interface Public {
    @:get("/") public function index(): String;
    @:get("/test") public function test(): String;

    @:sub public function api(): api.Api;
}
