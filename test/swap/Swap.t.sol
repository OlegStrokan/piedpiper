// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "forge-std/Test.sol";
import "../../src/swap/Swap.sol";

contract SwapTest is Test {
    Swap public swap;
    address public owner;
    address public firstUser;
    address public secondUser;

    function setUp() {
        owner = payable(vm.addr(2));
        firstUser = payable();
        vm.startPrank(owner);
        swap = new Swap(owner);
    }
}
