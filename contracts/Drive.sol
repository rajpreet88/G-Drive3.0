// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Drive {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // address owner = msg.sender;

    struct Access {
        address user;
        bool access; //true or false
    }

    mapping(address => string[]) value; //to store the list of ipfs urls(these urls are genearted in the IPFS network as per the data uploaded to blockchain) for a particular user like [ {address1: [url1, url2,url3] }, {address2: [url4, url5,url6]... }]

    mapping(address => Access[]) accessList; //to store the access details of the all to which a paricular user has given shared access to the data uploaded like [{address1: [{user:address2, bool: true },{user: address3, bool:false...}]}]

    mapping(address => mapping(address => bool)) ownership; // ownership[address1][address2] = true, ownership[address1][address3] = false ... address1 has given access to address2 so its bool is true ..sorta 2D array

    mapping(address => mapping(address => bool)) previousData; //to store the previous state of the data in blockchain unlike server

    //adding the ifps url in the value mapping array for a particular user
    function add(address _user, string memory url) external {
        value[_user].push(url);
    }

    //sharing the uploaded data to another user
    function allow(address _user) external {
        require(
            msg.sender == owner,
            "Only the owner of this contract can give shared access"
        );
        ownership[msg.sender][_user] = true;

        //check if this user address already in previousData or not to prevent duplicate shared addresses in accessList for given msg.sender
        if (previousData[owner][_user]) {
            for (uint256 i = 0; i < accessList[owner].length; i++) {
                if (accessList[owner][i].user == _user) {
                    accessList[owner][i].access = true;
                }
            }
        } else {
            accessList[owner].push(Access(_user, true));
            previousData[owner][_user] = true;
        }
    }

    //revoking shared access of an existing adress in the accessList
    function disallow(address _user) public {
        require(
            msg.sender == owner,
            "Only the owner of this contract can revoke shared access"
        );
        ownership[owner][_user] = false; //revoking access from the ownership
        for (uint256 i = 0; i < accessList[owner].length; i++) {
            //falsifying access in the accessList for the _user by the msg.sender
            if (accessList[owner][i].user == _user) {
                accessList[owner][i].access = false;
            }
        }
    }

    //displaying the images by the owner or the shared addresses
    function display(address _user) external view returns (string[] memory) {
        require(
            (_user == msg.sender || value[msg.sender].length > 0) ||
                ownership[_user][msg.sender],
            "Either you don't have any data to display(First try to upload some data) or don't have access to view the data"
        );

        return value[_user];
    }

    //displaying the list of all the shared addresses by the owner of the data
    function sharedAccess() public view returns (Access[] memory) {
        require(
            msg.sender == owner,
            "Only the owner of this contract can access the sharedList"
        );
        require(accessList[owner].length > 0, "You have no shared accessList");
        return accessList[owner];
    }
}
