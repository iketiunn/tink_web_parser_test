/**
 * This is generated by https://github.com/damoebius/swagger-hx-codegen
 * Brorrowed for testing the code first swagger json generator
 */

package api;

// import tink.http.containers.*;
// import tink.http.Response;
// import tink.web.routing.*;

/**
 * This is a sample server Petstore server.  You can find out more about     Swagger at [http://swagger.io](http://swagger.io) or on [irc.freenode.net, #swagger](http://swagger.io/irc/).      For this sample, you can use the api key `special-key` to test the authorization     filters.
 * @class Api
 * @param {(string)} [domainOrOptions] - The project domain.
 */
interface Api {


    /**
    * Add a new pet to the store
    * 
    **/
    @:post('/pet')
    function addPet(body:Pet):EmptyResponse;

    /**
    * Update an existing pet
    * 
    **/
    @:put('/pet')
    function updatePet(body:Pet):EmptyResponse;

    /**
    * Finds Pets by status
    * Multiple status values can be provided with comma separated strings
    **/
    @:get('/pet/findByStatus')
    function findPetsByStatus(query:{ status:Array<String> }):Array<Pet>;
    // function findPetsByStatus(status:Array<String>):Array<Pet>;

    /**
    * Finds Pets by tags
    * Muliple tags can be provided with comma separated strings. Use         tag1, tag2, tag3 for testing.
    **/
    @:get('/pet/findByTags')
    function findPetsByTags(query: { tags:Array<String> }):Array<Pet>;
    // function findPetsByTags(tags:Array<String>):Array<Pet>;

    /**
    * Find pet by ID
    * Returns a single pet
    **/
    @:get('/pet/$petId')
    function getPetById(petId:Int):Pet;

    /**
    * Updates a pet in the store with form data
    * 
    **/
    @:post('/pet/$petId')
    function updatePetWithForm(petId:Int,query: {name:String,status:String}):EmptyResponse;
    // function updatePetWithForm(petId:Int,name:String,status:String):EmptyResponse;

    /**
    * Deletes a pet
    * 
    **/
    @:delete('/pet/$petId')
    function deletePet(petId:Int, header: { api_key:String }):EmptyResponse;
    // function deletePet(api_key:String,petId:Int):EmptyResponse;

    /**
    * uploads an image
    * 
    * FIXME: Let's skip tink_multipart for now..
    **/
    // @:post('/pet/$petId/uploadImage')
    // function uploadFile(petId:Int,additionalMetadata:String,file:String):ApiResponse;

    /**
    * Returns pet inventories by status
    * Returns a map of status codes to quantities
    **/
    @:get('/store/inventory')
    function getInventory():InventoryResponse;

    /**
    * Place an order for a pet
    * 
    **/
    @:post('/store/order')
    function placeOrder(body:Order):Order;

    /**
    * Find purchase order by ID
    * For valid response try integer IDs with value >= 1 and <= 10.         Other values will generated exceptions
    **/
    @:get('/store/order/$orderId')
    function getOrderById(orderId:Int):Order;

    /**
    * Delete purchase order by ID
    * For valid response try integer IDs with positive integer value.         Negative or non-integer values will generate API errors
    **/
    @:delete('/store/order/$orderId')
    function deleteOrder(orderId:Int):EmptyResponse;

    /**
    * Create user
    * This can only be done by the logged in user.
    **/
    @:post('/user')
    function createUser(body:User):EmptyResponse;

    /**
    * Creates list of users with given input array
    * 
    * FIXME: body should be just array without a key, that will be a body issue
    **/
    // @:post('/user/createWithArray')
    // function createUsersWithArrayInput(body: Array<User>):EmptyResponse;

    /**
    * Creates list of users with given input array
    * 
    * FIXME: body should be just array without a key, that will be a body issue
    **/
    // @:post('/user/createWithList')
    // function createUsersWithListInput(body:Array<User>):EmptyResponse;

    /**
    * Logs user into the system
    * 
    **/
    @:get('/user/login')
    function loginUser(query: { username:String,password:String }):String;

    /**
    * Logs out current logged in user session
    * 
    **/
    @:get('/user/logout')
    function logoutUser():EmptyResponse;

    /**
    * Get user by user name
    * 
    **/
    @:get('/user/$username')
    function getUserByName(username:String):User;

    /**
    * Updated user
    * This can only be done by the logged in user.
    **/
    @:put('/user/$username')
    function updateUser(username:String,body:User):EmptyResponse;

    /**
    * Delete user
    * This can only be done by the logged in user.
    **/
    @:delete('/user/$username')
    function deleteUser(username:String):EmptyResponse;
}

typedef EmptyResponse = Null<String>;

typedef InventoryResponse = Map<String, Int>;

typedef Order = {
    ?id:Int,
    ?petId:Int,
    ?quantity:Int,
    ?shipDate:String,
    ?status:String,
    ?complete:Bool,
}

typedef Category = {
    ?id:Int,
    ?name:String,
}

typedef User = {
    ?id:Int,
    ?username:String,
    ?firstName:String,
    ?lastName:String,
    ?email:String,
    ?password:String,
    ?phone:String,
    ?userStatus:Int,
}

typedef Tag = {
    ?id:Int,
    ?name:String,
}

typedef Pet = {
    ?id:Int,
    ?category:Category,
    name:String,
    photoUrls:Array<String>,
    ?tags:Array<Tag>,
    ?status:String,
}

typedef ApiResponse = {
    ?code:Int,
    ?type:String,
    ?message:String,
}

