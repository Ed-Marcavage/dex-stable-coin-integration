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

    modifier depositedCollateralAndMintedDsc() {
        vm.startPrank(USER);
        // approve dsce contract to use amountCollateral amount of weth
        wethMock.approve(address(dsce), amountCollateral);
        dsce.depositCollateralAndMintDsc(
            address(wethMock),
            amountCollateral,
            amountToMint
        );
        vm.stopPrank();
        _;
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
            1e18, // WETH
            1e18, // Min TSWAP-Token
            10e18, // Max Link
            uint64(block.timestamp)
        );

        vm.stopPrank();
        _;
    }

    function testDepositDscIntoTswap()
        external
        depositedCollateralAndMintedDsc
    {
        vm.startPrank(USER);

        wethMock.approve(address(pool), 10e18);
        dsc.approve(address(pool), 10e18);

        pool.deposit(
            1e18, // WETH
            1e18, // Min TSWAP-Token
            10e18, // Max Link
            uint64(block.timestamp)
        );

        vm.stopPrank();
    }
}
