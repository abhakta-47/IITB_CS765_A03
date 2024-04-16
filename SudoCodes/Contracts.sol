pragma solidity ^0.8.0;

contract News {
    struct Vote {
        address voter;
        bool voteValue;
    }

    address public author;
    string public title;
    string public body;
    string[] public topics;
    bool public truthValue;
    uint public timestamp;
    bytes32 public newsId;
    Vote[] public votes;

    bool public detectedTruthy;
    uint public accuracy;

    constructor(address _author, string memory _title, string memory _body, string[] memory _topics, bool _truthValue) {
        author = _author;
        title = _title;
        body = _body;
        topics = _topics;
        truthValue = _truthValue;
        timestamp = block.timestamp;
        newsId = keccak256(abi.encodePacked(_author, _title, _body, _topics, _truthValue, timestamp));
    }

    function castVote(address _voter, bool _voteValue) public {
        votes.push(Vote(_voter, _voteValue));
    }

    function calculateAccuracy() public {
        uint[2] memory newsAccuracies;
        for (uint i = 0; i < topics.length; i++) {
            uint[2] memory newsAccuraciesTopic = calculateNewsAccuracyTopic(topics[i]);
            newsAccuracies[0] += newsAccuraciesTopic[0];
            newsAccuracies[1] += newsAccuraciesTopic[1];
        }

        uint totalTrueVotes = newsAccuracies[0];
        uint totalFalseVotes = newsAccuracies[1];
        uint totalVotes = totalTrueVotes + totalFalseVotes;

        if (totalVotes > 0) {
            if (totalTrueVotes > totalFalseVotes) {
                detectedTruthy = true;
                accuracy = (totalTrueVotes * 100) / totalVotes;
            } else {
                detectedTruthy = false;
                accuracy = (totalFalseVotes * 100) / totalVotes;
            }
        } else {
            detectedTruthy = truthValue;
            accuracy = 0;
        }
    }

    function calculateNewsAccuracyTopic(string memory _topic) private view returns (uint[2] memory) {
        uint[2] memory newsAccuraciesTopic;
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voteValue == truthValue) {
                newsAccuraciesTopic[0]++;
            } else {
                newsAccuraciesTopic[1]++;
            }
        }
        return newsAccuraciesTopic;
    }
}


contract Voter {
    address public voterAddress;
    string public voterType;
    mapping(address => bool) public voted;

    constructor() {
        voterAddress = msg.sender;
    }

    function vote(News news, bool voteValue) public {
        require(!voted[msg.sender], "Already voted");
        news.castVote(msg.sender, voteValue);
        voted[msg.sender] = true;
    }
}

contract Vote {
    struct VoterInfo {
        address voter;
        uint amountDeposited;
        address newsItem;
        bool voteValue;
    }

    VoterInfo[] public votes;

    event AccuracyCalculationTriggered(address indexed newsItem);


    function vote(address _voter, uint _amountDeposited, address _newsItem, bool _voteValue) public {
        votes.push(VoterInfo(_voter, _amountDeposited, _newsItem, _voteValue));

        if (votes.length >= 100) {
            emit AccuracyCalculationTriggered(_newsItem);
        }
    }
}