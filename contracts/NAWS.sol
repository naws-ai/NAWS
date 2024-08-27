// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts-5.0.0/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "openzeppelin-contracts-5.0.0/access/Ownable.sol";
import "openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Votes.sol";

contract NAWS is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {

    // Cold wallet addresses
    address public constant NAWS_COLDWALLET_ECOSYSTEM = 0xe71277118C276Bef6F722F50F039EfD7aEe5AFAF;
    address public constant NAWS_COLDWALLET_TEAM = 0x40ea4678523578839DE6ABcfA74711d38FBd5132;
    address public constant NAWS_COLDWALLET_INVESTMENT = 0xdD668C685d166b950BF3efCb53e49ED9E794976e;
    address public constant NAWS_COLDWALLET_MARKETING = 0x9afCD842F6dbCc63C5521E6593DCda5c670F3C4D;
    address public constant NAWS_COLDWALLET_RESERVE = 0xa9671aA2Ee1AbBC63002053A755642C1A31D9347;

    constructor(address initialOwner)
        ERC20("NAWS", "NAWS")
        Ownable(initialOwner)
        ERC20Permit("NAWS")
    {
        // Mint 20% of the total supply to each cold wallet
        uint256 initialSupply = 10000000000 * 10 ** decimals();
        uint256 allocation = initialSupply / 5; // 20% allocation

        _mint(NAWS_COLDWALLET_ECOSYSTEM, allocation);
        _mint(NAWS_COLDWALLET_TEAM, allocation);
        _mint(NAWS_COLDWALLET_INVESTMENT, allocation);
        _mint(NAWS_COLDWALLET_MARKETING, allocation);
        _mint(NAWS_COLDWALLET_RESERVE, allocation);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
