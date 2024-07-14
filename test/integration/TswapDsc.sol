// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TSwapPool} from "../../src/PoolFactory.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {DeployDSC} from "../../script/DeployDSC.s.sol";

contract TswapDsc is Test {
    // TSwap
    TSwapPool pool;
    ERC20Mock poolToken;
    ERC20Mock weth;

    // DSC
    // DeployDecentralizedStableCoin deployDecentralizedStableCoin;

    address liquidityProvider = makeAddr("liquidityProvider");
    address user = makeAddr("user");

    function setUp() external {
        // deployDecentralizedStableCoin = new DeployDecentralizedStableCoin();
        // (dsc, dsce, config) = deployDecentralizedStableCoin.run();
        // (ethUsdPriceFeed, wbtcUsdPriceFeed, weth, wbtc, ) = config
        //     .activeNetworkConfig();
        // ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);
        // ERC20Mock(wbtc).mint(USER, STARTING_USER_BALANCE);
    }
}
