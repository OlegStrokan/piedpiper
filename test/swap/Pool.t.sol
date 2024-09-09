// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "forge-std/Test.sol";
import "../../src/swap/Pool.sol";
import "../../src/swap/token/LPToken.sol";

contract PoolTest is Test {
    Pool pool;
    StorinToken storinToken;
    LPToken lpToken;
    address payable public owner;
    address payable public firstProvider;
    address payable public secondProvider;

    function setUp() {
        owner = payable(vm.addr(1));
        firstProvider = payable(vm.addr(2));
        secondProvider = payable(vm.addr(3));
        vm.deal(owner, 2 ether);
        vm.deal(firstProvider, 2 ether);
        vm.deal(secondProvider, 1 ether);
        lpToken = new LPToken();
        storinToken = new StorinToken();
        vm.prank(owner);
        pool = new Pool();
    }

    function testAddToken() public {
        vm.prank(owner);
        pool.addToken(address(myToken), address(lpTokens));
    }

    function createPool() private {}
}
