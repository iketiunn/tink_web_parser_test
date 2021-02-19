package server.api.impl;

class Public implements server.api.Public {
    public function new() {}
    public function index() {
        return "Hello TinkBell";
    }

    public function test() {
        return "This is test route";
    }

    public function testId(id) {
        return id;
    }

    public function api() {
        return new server.api.impl.Api();
    }
}
