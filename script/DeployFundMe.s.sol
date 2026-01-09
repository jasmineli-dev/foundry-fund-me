pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    uint256 public version;

    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        //Get Active Network Config and ETH/USD Price feed address
        (address priceFeedAddress, uint256 currentVersion) = helperConfig
            .activeNetworkConfig();
        // address priceFeedAddress = helperConfig.activeNetworkConfig().priceFeed; ok too
        version = currentVersion;
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
