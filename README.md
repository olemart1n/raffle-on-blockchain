# Provably random raffle contracts

## About
This contract uses chainlink VRF & Automation
___
This code is to create a provably random smart contract lottery.

1. Users can enter by paying for a ticket.
    1. The ticket fees are going to go to the winner during the draw
2. After x time the lottery will automatically draw a winner.
    1. This will be done programmatically
3. Using Chainlink VRF & Chainlink
    1. Chainlink VRF -> Randomness
    2. Chainlink automation -> Time-based trigger
