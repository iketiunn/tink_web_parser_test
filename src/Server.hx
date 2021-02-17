package;

import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;

// import pet.api.impl.Public;

class Server {
    static function main() {
        var container = new NodeContainer(8080); 
        var root = new api.impl.Public();
        var router = new Router<api.Public>(root);
        container.run(function(req) {
            return router.route(Context.ofRequest(req))
                .recover(OutgoingResponse.reportError);
        });
    }
}

// class Root {
//     public function new() {}
    
//     @:get('/')
//     @:get('/$name')
//     public function hello(name = 'World')
//         return 'Hello, $name!';
// }
