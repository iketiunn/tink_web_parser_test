package api.impl;

class Public implements api.Public {
    public function new() {}
    public function index() {
        return "Hello TinkBell";
    }

    public function test() {
        return "This is test route";
    }

    public function named(name = "Tom") {
        return "This is named route visit by " + name;
    }
}