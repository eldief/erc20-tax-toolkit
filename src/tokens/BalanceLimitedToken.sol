// SPDX-License-Identifier: MIT

/*

      .oooo.               oooooo     oooo           oooo                      o8o                       
     d8P'`Y8b               `888.     .8'            `888                      `"'                       
    888    888 oooo    ooo   `888.   .8'    .oooo.    888   .ooooo.  oooo d8b oooo  oooo  oooo   .oooo.o 
    888    888  `88b..8P'     `888. .8'    `P  )88b   888  d88' `88b `888""8P `888  `888  `888  d88(  "8 
    888    888    Y888'        `888.8'      .oP"888   888  888ooo888  888      888   888   888  `"Y88b.  
    `88b  d88'  .o8"'88b        `888'      d8(  888   888  888    .o  888      888   888   888  o.  )88b 
     `Y8bd8P'  o88'   888o       `8'       `Y888""8o o888o `Y8bod8P' d888b    o888o  `V88V"V8P' 8""888P' 

*/

pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {BalanceLimiter} from "../contracts/BalanceLimiter.sol";

/**
 * @title BalanceLimitedToken
 * @author 0xValerius
 * @notice A custom ERC20 token with a balance limitation feature.
 * @dev Inherits from OpenZeppelin's ERC20 and the BalanceLimiter contracts.
 */
contract BalanceLimitedToken is ERC20, BalanceLimiter {
    /**
     * @notice Constructs a new BalanceLimitedToken.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _basePointsBalanceLimit The base points for the balance limit.
     */
    constructor(string memory _name, string memory _symbol, uint256 _basePointsBalanceLimit)
        ERC20(_name, _symbol)
        BalanceLimiter(_basePointsBalanceLimit)
    {}

    /**
     * @notice Overrides the _beforeTokenTransfer function to enforce balance limits.
     * @param from The sender address.
     * @param to The recipient address.
     * @param amount The amount to be transferred.
     * @dev This function is called by the inherited ERC20 contract.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override(ERC20, BalanceLimiter)
    {
        BalanceLimiter._beforeTokenTransfer(from, to, amount);
    }
}
