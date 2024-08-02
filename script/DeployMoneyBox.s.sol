//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MoneyBox} from "../src/MoneyBox.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployMoneyBox is Script {
    function run() external returns (MoneyBox) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        uint256 goalAmount = 10000000000000000;

        vm.startBroadcast();
        MoneyBox moneyBox = new MoneyBox(ethUsdPriceFeed, goalAmount);
        vm.stopBroadcast();
        return moneyBox;
    }
}
