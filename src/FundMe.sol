// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    AggregatorV3Interface private sPriceFeed;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    // constant variable must be assigned a value at compile time
    address public immutable MY_OWNER;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    constructor(address priceFeed) {
        MY_OWNER = msg.sender;
        sPriceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(sPriceFeed) >= MINIMUM_USD, // function getConversionRate(uint256 ethAmount,AggregatorV3Interface pricefeed)
            "You need to spend more ETH!"
        );
        // require(
        //     PriceConverter.getConversionRate(msg.value, sPriceFeed) >=
        //         MINIMUM_USD,
        //     "You need to spend more ETH!"
        // );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        return sPriceFeed.version();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal {
        if (msg.sender != MY_OWNER) revert FundMe_NotOwner(); //gas efficient
    }

    function withdraw() public onlyOwner {
        uint256 length = funders.length;
        for (uint256 funderIndex = 0; funderIndex < length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    //Any ETH sent to the contract triggers fund().
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return sPriceFeed;
    }

    function getOwner() public view returns (address) {
        return MY_OWNER;
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly
