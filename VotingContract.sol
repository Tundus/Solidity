pragma solidity ^0.4.25;

contract Voting {
    
    //We create a new struct for possible 'Runners'. 
    //Although possible 'Runners' are predefined as 0, 1 and 2
    //the stuct identifies them by their names
    struct Runners {
        bytes32 name;
        uint voteCount;
    }
    
    //This is a struct for the voter. 
    //Weight will enable us to let only those vote who has been
    //authorized by the owner of the contract. The trick is that 
    //the default value is zero
    struct Voter {
        bool voted;
        uint voteIndex;
        uint weight;
    }
    
    //The owner of the contract has special rights
    //hence we need to track her closely
    address public owner;
    //We need the mapping info for the voters
    mapping(address => Voter) public voters;
    //And to include our options into an array
    Runners[] public runners;
    //This is the address that can become owner
    address public delegate;
    //Creator has a special privilage and could always take back control
    address public creatorOwner;
    
    //Let's create a voting event. Should you need different 
    //runners then the preset 3 values they should be added here 
    //by amending the below constructor
    constructor(address _delegate) public{
        //creator of the event will be the owner
        owner = msg.sender;
        
        //As per the requirement let's set and push the 
        //3 values (names) and their actual voteCount to the
        //state variable array we created earlier
        runners.push(Runners(0,0));
        runners.push(Runners(1,0));
        runners.push(Runners(2,0));
        
        delegate = _delegate;
        
    }
    
    //Let's conduct the actual voting.
    //Only authorized voters can vote! This is 
    //satisfied through the autorize function
    function voting(uint voteIndex) public {
        //All authorized voters weight should be one
        require(voters[msg.sender].weight == 1, "You're not authorized to vote.");
        //Check if the voter hasn't voted yet '
        require(!voters[msg.sender].voted, "You already voted.");
        //Make sure voter cannot vote again
        //by setting his vote flag to voted
        voters[msg.sender].voted = true;
        
        //Votig options are referred by their index
        voters[msg.sender].voteIndex = voteIndex;
        
        runners[voteIndex].voteCount += voters[msg.sender].weight;
        
    } 
    
    
    //This is the authorization function in which
    //the creator gives the right to addresses to voter
    function authorize(address voter) public {
        require(msg.sender == owner);
        //require(!voters[voter].voted);
        require(voters[voter].weight == 0);
        voters[voter].weight = 1; 
    }
    
    //Let's gather vote results
    function theWinnerIs() public view returns (uint theWinnerIs_) {
        require(msg.sender == owner, "Reports to creator(s) only!");
        
        uint winningVoteCount = 0;
        for (uint i=0; i < runners.length; i++) {
            if(runners[i].voteCount > winningVoteCount) {
                winningVoteCount = runners[i].voteCount;
                theWinnerIs_ = i;
            }
        }
    }
    
    function getResults() view public returns(uint, uint, uint) {
        return(runners[0].voteCount, runners[1].voteCount, runners[2].voteCount);
            
    }
    
    function delegateOwner(address to) public {
        require(to == delegate, "This address is not on my list");
        creatorOwner = owner;
        owner = to;
        }
    
    function rollBackOwner() {owner = creatorOwner;}
    
}
