// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    //code goes here..
    //string public name;
    //declaring the owner who owns the site
    address public owner;

    struct Item {
        //arbetory datatypes - datastructure
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    //process similar to key value pairs, used to save the stuff to the blockchain
    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    //custome modifier
    //it modifies the behaviour of a function that only the owner can do the transaction
    modifier onlyOwner() {
        require(msg.sender == owner);
        //this line below represents the function body
        _;
    }

    constructor() {
        //name = "Dappazon";
        //person who is deploying the smart contract to the blockchain.
        owner = msg.sender;
        
    }

    //List Products
    //named function
    function list(
        //unsigned integer - means no -ve values
        uint256 _id,
        //memory is the data location 
        string memory _name, 
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock 
     ) public onlyOwner {
        //whenever anything is placed into this function it evaluate it with true/false
        //require(msg.sender == owner);

        //step - by - step instuctions
        
        //Create Product/Item struct
        Item memory item = Item(
            _id, 
            _name, 
            _category, 
            _image, 
            _cost, 
            _rating, 
            _stock
            );

        //Save Item struct to blocckchain
        items[_id] = item;

        //Emit an event
        emit List(_name, _cost, _stock);



    }

    //Buy Products
    function buy(uint256 _id) public payable {
        //receive the funds i.e crypto

        //Fetch item
        Item memory item = items[_id];

        //Require enough ether to buy item
        require(msg.value >= item.cost);

        //Require item is in stock 
        require(item.stock > 0);

        //create an order
        //unique timestamp on the each block of the chain with the current time
        //globally availible inside solidity
        Order memory order = Order(block.timestamp, item);

        //save order to chain
        orderCount[msg.sender]++;  // <-- Order ID
        orders[msg.sender][orderCount[msg.sender]] = order;


        //subtract stock
        items[_id].stock = item.stock - 1;

        //Emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    //Withdrow Funds
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
