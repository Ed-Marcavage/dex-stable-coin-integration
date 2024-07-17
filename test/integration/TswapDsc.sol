// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TSwapPool} from "../../src/PoolFactory.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract TswapDsc is Test {
    // TSwap
    TSwapPool pool;
    ERC20Mock poolToken;
    ERC20Mock wethMock;

    // DSC
    DeployDSC deployDSC;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config;
    address ethUsdPriceFeed;
    address wbtcUsdPriceFeed;
    address weth;
    address wbtc;
    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;

    address liquidityProvider = makeAddr("liquidityProvider");
    address public USER = makeAddr("user");
    uint256 STARTING_USER_BALANCE = 100 ether;

    function setUp() external {
        // Deploy DSC
        deployDSC = new DeployDSC();
        (dsc, dsce, config) = deployDSC.run();
        (ethUsdPriceFeed, wbtcUsdPriceFeed, weth, wbtc, ) = config
            .activeNetworkConfig();

        wethMock = ERC20Mock(weth);

        // Deploy TSwap
        // wethMock = new ERC20Mock(
        //     "Wrapped Ether",
        //     "WETH",
        //     address(this),
        //     1000000000000000000000000000
        // );

        pool = new TSwapPool(address(dsc), weth, "LTokenA", "LA");
        wethMock.mint(USER, STARTING_USER_BALANCE);
        // ERC20Mock(wbtc).mint(USER, STARTING_USER_BALANCE);
    }

    modifier MintDscAndDepositIntoTswap() {
        vm.startPrank(USER);
        //depositedCollateralAndMintedDsc
        wethMock.approve(address(dsce), amountCollateral);
        dsce.depositCollateralAndMintDsc(
            address(wethMock),
            amountCollateral,
            amountToMint
        );

        //testDepositDscIntoTswap
        wethMock.approve(address(pool), 10e18);
        dsc.approve(address(pool), 10e18);

        pool.deposit(
            1e18, // WETH`
            1e18, // Min TSWAP-Token
            10e18, // Max Link
            uint64(block.timestamp)
        );

        vm.stopPrank();
        _;
    }

    function testDepositDscIntoTswap() external MintDscAndDepositIntoTswap {
        // console.log("USER dsc balance", dsc.balanceOf(USER) / 1e18);
        // console.log("USER pool balance", pool.balanceOf(USER) / 1e18);

        // log pool balance of ETH
        console.log(
            "Before pool balance of ETH",
            wethMock.balanceOf(address(pool))
        );
        // log pool balance of TSWAP
        console.log("Before pool balance of dsc", dsc.balanceOf(address(pool)));

        //   USER dsc balance 90
        //   USER pool balance 1
        //   pool balance of ETH 1
        //   pool balance of dsc 10
        vm.startPrank(USER);
        dsc.approve(address(pool), 1e18);
        pool.swapExactInput(dsc, 1e18, wethMock, 1e16, uint64(block.timestamp));
        vm.stopPrank();

        // log pool balance of ETH
        console.log(
            "After pool balance of ETH",
            wethMock.balanceOf(address(pool))
        );
        // log pool balance of TSWAP
        console.log("After pool balance of dsc", dsc.balanceOf(address(pool)));
    }

    // @todo
    // determines why ETH isnt round as is 909090909090909091
    // play around with view func that calc price
}
