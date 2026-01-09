pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed
        uint256 version;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    //A struct is a reference type, not a value type.
    // Does not live in contract storage
    // Is not passed via calldata
    // Exists only during function execution
    // Therefore, it must live in memory.

    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
                version: 4
            });
    }

    function getMainnetNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                priceFeed: address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
                version: 4
            });
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockAggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_ANSWER
        );
        uint256 version = mockAggregator.version();
        console.log("version:", version);
        vm.stopBroadcast();
        return
            NetworkConfig({
                priceFeed: address(mockAggregator),
                version: version
            });
    }
    //     private
    //     view
    //     returns (NetworkConfig memory)
    // {
    //     MockAggregatorV3Interface mockAggregator = new MockAggregatorV3Interface();
    //     return NetworkConfig({priceFeed: address(mockAggregator)});
    // }

    // function getPriceFeed() public view returns (address) {
    //     return address(new PriceConverter());
    // }
}
