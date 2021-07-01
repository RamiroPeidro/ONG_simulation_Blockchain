// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

contract GreenPeace{
    
    mapping(address => bool) isOracle;
    mapping (address=>bool) isOwner;
    mapping (address=>bool) isMember;
    mapping(address=>Owner) owners;
    
    uint8 period;
    address ownerAddress;
    
    struct Owner{
        uint tokens;
    }
    
    struct Member{
        string name;
        uint tokens;
    }

    struct Project{
        uint description;
        uint tokens;
        uint id;
        bool active;
        address owner;
        uint price;
    }
    
    mapping(uint=>Project) idToProject;
    mapping(address=>Member) members;
    Member [] membersArray;

    constructor(){
        isOwner[msg.sender] = true;
        Owner memory new_owner = Owner({
            tokens : 0
        });
        
        owners[msg.sender] = new_owner;
        period = 1;
        ownerAddress = msg.sender;
    }
    
    function add_oracle(address _newOracle) public{
        require(isOwner[msg.sender]);
        isOracle[_newOracle] = true;
    }

    function add_member(string memory _name, address _address) public{
        require(isOwner[msg.sender]);
        Member memory newMember = Member({
            name: _name,
            tokens: 0
        });
        
        members[_address] = newMember;
        isMember[_address] = true;
        membersArray.push(newMember);
    }
    
    function updatePeriod(uint8 _period) public{
        require(isOracle[msg.sender]);
        require(_period == 1 || _period == 2 || _period==3);
        period = _period;
    }
    
    function add_project(uint _description, uint _id, address _projectOwner, uint _price) public{
        require(isOwner[msg.sender]);
        Project memory newProject = Project({
            description : _description,
            tokens: 0,
            id : _id,
            active : true,
            owner: _projectOwner,
            price: _price
        });
        
        idToProject[_id] = newProject;
    }
    
    
    function disable_member(address _member) public {
        require(isOwner[msg.sender]);
        isMember[_member] = false;
    }
    
    function disbale_project(uint _id) public{
        require(idToProject[_id].owner == msg.sender);
        idToProject[_id].active = false;
    }
    
    function reAsingProject(address _newAddress, uint _id) public{
        require(idToProject[_id].owner == msg.sender);
        idToProject[_id].owner = _newAddress;
    }

    function assignTokensToProject(uint _projectId, uint _tokens) public{
        require(period == 2);
        require(isMember[msg.sender], "You are not a member");
        require(idToProject[_projectId].description !=0, "The id does not match any project");
        require(members[msg.sender].tokens >= idToProject[_projectId].price, "You do not have enough tokens");
        
        members[msg.sender].tokens -= _tokens;
        idToProject[_projectId].tokens += _tokens;
    }
    
    
    function assignTokensToMembers(uint _tokens, address _member) public{
        require(period == 1);
        require(isOracle[msg.sender]);
        members[_member].tokens += _tokens;
    }
    
    function reAsignTokens() public{
        require(period==3);
        require(isOwner[msg.sender]);
        for(uint i=0; i<membersArray.length; i++){
            owners[ownerAddress].tokens += membersArray[i].tokens;
            membersArray[i].tokens = 0;
        }
        period = 1;
    }
    
}