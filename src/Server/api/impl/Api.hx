package server.api.impl;

class Api implements server.api.Api {
    public function new () {}

    public function addPet(body) {
        trace(body);

        return "";
    }

    public function updatePet(body) {
        trace(body);

        return "";
    }

    public function findPetsByStatus(query) {
        trace(query);

        return [
            pet
        ];
    }

    public function findPetsByTags(query) {
        trace(query);

        return [pet];
    }

    public function getPetById(petId) {
        trace(petId);

        return pet;
    }

    public function updatePetWithForm(petId, query) {
        trace(petId, query);

        return "";
    }

    public function deletePet(petId, header) {
        trace(petId, header);

        return "";
    }

    public function getInventory() {
        return [
            "additionalProp1" => 26,
            "additionalProp2" => 17,
            "additionalProp3" => 32,
          ];
    }

    public function placeOrder(body) {
        trace(body);

        return body;
    }

    public function getOrderById(orderId) {
        trace(orderId);

        return order;
    }

    public function deleteOrder(orderId) {
        trace(orderId);

        return "";
    }

    public function createUser(body) {
        trace(body);

        return "";
    }

    public function loginUser(query) {
        trace(query);

        return "ok";
    }

    public function logoutUser() {
        return "";
    }

    public function getUserByName(username) {
        trace(username);

        return user;
    }

    public function updateUser(username, body) {
        trace(username, body);

        return "";
    }

    public function deleteUser(username) {
        trace(username);

        return "";
    }

    // Healpers
    var pet = {
        id: 1,
        category: {
            id: 1,
            name: 'cat 1'
        },
        name: 'mock pet 1',
        photoUrls: ['https://google.com'],
        tags: [
            { id: 1, name: 'tag 1' }
        ],
        status: 'ok'
    };
    
    var order = {
        id: 1,
        petId: 1,
        quantity: 10,
        shipDate: '2020-02-17T00:08:00Z',
        status: 'ok',
        complete: true
    };
    
    var user = {
        id:1,
        username: 'user 1',
        firstName: 'Jhon',
        lastName:'Snow',
        email:'jhon.snow@bigalice.com',
        password:'secret',
        phone:'+886958880050',
        userStatus:1,
    };
}
