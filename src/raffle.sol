// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions



// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

// import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
/**
 * @title Lottery 
 * @author Ole Martin
 * @notice This contract is for creating a sample raffle
 * @dev implement chainlink VRFv2
 */


contract  Raffle is VRFConsumerBaseV2 {

    error Raffle__notEnouthEthSent();
    error Raffle__transferFailed();
    error Raffle__raffleNotOpen();

    enum RaffleState {
        OPEN,
        CALCULATING
    }
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    
    address payable [] private s_players;
    uint256 private s_lastTimestamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

/**EVENTS */

    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);
    constructor (uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator){
        s_raffleState = s_raffleState.OPEN;

        i_entranceFee = entranceFee;
        i_interval = interval;
        i_gasLane = gasLane;
        s_lastTimestamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__notEnouthEthSent();
        }
        if(s_raffleState != s_raffleState.OPEN) {
            revert Raffle__raffleNotOpen();
        }
        s_players.push(payable(msg.sender));
    }

    function pickWinner() public {
        if(block.timestamp - s_lastTimestamp < i_interval) {
            revert();
        }
        s_raffleState = s_raffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fullfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = s_raffleState.OPEN;

        s_players = new address payable[](0);
        s_lastTimestamp = block.s_lastTimestamp;

        (bool success,) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__transferFailed();
        }
        emit PickedWinner(winner);
    }


    function getEntranceFee () external view returns(uint256) {
        return i_entranceFee;
    }
}