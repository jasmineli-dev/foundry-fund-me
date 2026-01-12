pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    uint256 public version;

    function run() public returns (FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        //Get Active Network Config and ETH/USD Price feed address
        address priceFeedAddress = helperConfig
            .getConfigByChainId(block.chainid)
            .priceFeed;
        uint256 currentVersion = helperConfig
            .getConfigByChainId(block.chainid)
            .version;
        // (address priceFeedAddress, uint256 currentVersion) = helperConfig
        //     .getConfigByChainId(block.chainid);
        // address priceFeedAddress = helperConfig.activeNetworkConfig().priceFeed; ok too
        version = currentVersion;
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}
