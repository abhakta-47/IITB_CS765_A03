// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract News {

    struct Voter {
        address voter_id;
        uint rating;
        bool vote;
    }

    bytes32 public id;
    bytes32 public title;
    address public publisher;

    mapping(address => Voter) public voters;
    // uint num_voters;
    

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    constructor(bytes32[] memory proposalNames) {
        publisher = msg.sender;
        voters[publisher].rating = 0;
        num_voters = 0;
    }

    function vote(bool value) public {
        // if msg.sender already voted skip


        Voter storage sender = voters[msg.sender];
        // require(sender.weight != 0, "Has no right to vote");
        // require(!sender.voted, "Already voted.");

        // sender.voted = true;
        sender.vote = value;
        num_voters++;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        // proposals[proposal].voteCount += sender.weight;
    }
    
    function newsTruthfulNess() public view returns (bool is_true){
        require(num_voters>100, "Not enough votes casted");
        uint true_count = 0;
        uint fake_count = 0;
        uint total_count = voters.length;
        for( uint v=0; v < voters.length; v++)
            if (voters[v].vote) true_count += 1;
            else ++fake_count;
        require( (true_count >= 2/3*total_count) || (fake_count >= 2/3*total_count), "deffered to next round"  );
        if( true_count >= 2/3*total_count )
            is_true = true;
        if( fake_count >= 2/3*total_count )
            is_true = false;
    }

}