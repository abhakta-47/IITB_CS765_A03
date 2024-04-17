pragma solidity ^0.8.0;


contract NewsDetection {

    struct News{
        address immutable author;
        string immutable title;
        string immutable body;
        string[] immutable topics;
        bytes32 immutable newsId;
        uint immutable timestamp;
    }

    News immutable news;

    uint constant deposit = 10 ether;

    bool detectedAccuracy;
    bool isLocked;
    uint accuracy;
    Vote[] votes;
    uint private totalDeposit;

    struct Vote {
        address voter;
        bool voteValue;
    }

    constructor(address _author, string memory _title, string memory _body, string[] memory _topics) {
        news = News({
            author: _author,
            title: _title,
            body: _body,
            topics: _topics,
            newsId: keccak256(abi.encodePacked(_author, _title, _body, block.timestamp)),
            timestamp: block.timestamp
        });
        isLocked = false;
    }
    
    function hasVoted(address _voter) private view returns (bool) {
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voter == _voter) {
                return true;
            }
        }
        return false;
    }

    function castVote(address _voter, bool _voteValue) public {
        require(!isLocked, "Voting is locked");
        require(!hasVoted(_voter), "Already voted");
        require(msg.value == deposit, "Incorrect deposit amount");
        

        votes.push(Vote(_voter, _voteValue));
        totalDeposit += deposit;

        if (votes.length % 100 == 0) {
            calculateAccuracy();
        }
    }

    function calculateNewsAccuracyTopic(string memory _topic) private view returns (uint[2] memory) {
        uint[2] memory newsAccuraciesTopic;
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voteValue == true) {
                newsAccuraciesTopic[0]++;
            } else {
                newsAccuraciesTopic[1]++;
            }
        }
        return newsAccuraciesTopic;
    }

    function calculateAccuracy() private {
        uint[2] memory newsAccuracies;
        for (uint i = 0; i < topics.length; i++) {
            uint[2] memory newsAccuraciesTopic = calculateNewsAccuracyTopic(topics[i]);
            newsAccuracies[0] += newsAccuraciesTopic[0];
            newsAccuracies[1] += newsAccuraciesTopic[1];
        }

        uint totalTrueVotes = newsAccuracies[0];
        uint totalFalseVotes = newsAccuracies[1];
        uint totalVotes = totalTrueVotes + totalFalseVotes;

        require(totalVotes > 0, "No votes cast");

        if (totalTrueVotes/totalVotes > 0.6) {
            detectedAccuracy = true;
            accuracy = (totalTrueVotes * 100) / totalVotes;
        } else if (totalFalseVotes/totalVotes > 0.6){
            detectedAccuracy = false;
            accuracy = (totalFalseVotes * 100) / totalVotes;
        } else {
            revert("Draw");
        }
        distributeRewards();
        lockVotes();
    }

    function distributeRewards() private {
        uint correctVotes = 0;
        
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voteValue == detectedAccuracy) 
                correctVotes++;
        }

        uint rewardAmount = totalDeposit / correctVotes;

        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voteValue == detectedAccuracy) {
                rewardVoter(votes[i].voter, rewardAmount);
            }
        }
    }

    function rewardVoter(address _voter, uint rewardAmount) private {
        payable(_voter).transfer(rewardAmount);        
    }
    
    function lockVotes() private {
        isLocked = true;
    }
}