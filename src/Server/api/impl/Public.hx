package api.impl;

class Public implements api.Public {
    public function new() {}
    public function index() {
        return "Hello TinkBell";
    }

    public function test() {
        return "This is test route";
    }

    public function api() {
        return new api.impl.Api();
    }
}
