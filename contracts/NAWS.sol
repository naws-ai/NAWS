// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./openzeppelin-contracts-5.0.0/token/ERC20/ERC20.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "./openzeppelin-contracts-5.0.0/access/Ownable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Votes.sol";

contract NAWS is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {

    // Cold wallet addresses
    address public constant NAWS_COLDWALLET_ECOSYSTEM = 0xe71277118C276Bef6F722F50F039EfD7aEe5AFAF;
    address public constant NAWS_COLDWALLET_TEAM = 0x40ea4678523578839DE6ABcfA74711d38FBd5132;
    address public constant NAWS_COLDWALLET_INVESTMENT = 0xdD668C685d166b950BF3efCb53e49ED9E794976e;
    address public constant NAWS_COLDWALLET_MARKETING = 0x9afCD842F6dbCc63C5521E6593DCda5c670F3C4D;
    address public constant NAWS_COLDWALLET_RESERVE = 0xa9671aA2Ee1AbBC63002053A755642C1A31D9347;

    struct TimelockInfo {
        uint256 releaseTime; // Release timestamp
        uint256 amount; // Amount locked
    }

    mapping(address => TimelockInfo[]) public timelocks; // Mapping of address to its timelocks

    constructor(address initialOwner)
        ERC20("NAWS", "NAWS")
        Ownable(initialOwner)
        ERC20Permit("NAWS")
    {
        uint256 initialSupply = 10000000000 * 10 ** decimals();
        _mint(NAWS_COLDWALLET_ECOSYSTEM, 1000000000 * 10 ** decimals());
        _mint(NAWS_COLDWALLET_TEAM, 500000000 * 10 ** decimals());
        _mint(NAWS_COLDWALLET_INVESTMENT, 500000000 * 10 ** decimals());
        _mint(NAWS_COLDWALLET_MARKETING, 500000000 * 10 ** decimals());
        _mint(NAWS_COLDWALLET_RESERVE, 0); 

        _initializeTimelocks();
    }

    // Initialize timelocks for each address
    function _initializeTimelocks() internal {
        uint256 month = 30 days;

        // Ecosystem (Airdrop) timelocks for 18 months
        for (uint256 i = 1; i <= 17; i++) {
            timelocks[NAWS_COLDWALLET_ECOSYSTEM].push(TimelockInfo(block.timestamp + i * month, 55555556 * 10 ** decimals()));
        }
        timelocks[NAWS_COLDWALLET_ECOSYSTEM].push(TimelockInfo(block.timestamp + 18 * month, 55555552 * 10 ** decimals())); // Adjusted to make the total 2 billion

        // Team timelocks for 24 months
        for (uint256 i = 1; i <= 23; i++) {
            timelocks[NAWS_COLDWALLET_TEAM].push(TimelockInfo(block.timestamp + i * month, 62500000 * 10 ** decimals()));
        }
        timelocks[NAWS_COLDWALLET_TEAM].push(TimelockInfo(block.timestamp + 24 * month, 62500000 * 10 ** decimals())); // No adjustment needed as total fits 2 billion

        // Investment timelocks for 24 months (same as Team)
        for (uint256 i = 1; i <= 23; i++) {
            timelocks[NAWS_COLDWALLET_INVESTMENT].push(TimelockInfo(block.timestamp + i * month, 62500000 * 10 ** decimals()));
        }
        timelocks[NAWS_COLDWALLET_INVESTMENT].push(TimelockInfo(block.timestamp + 24 * month, 62500000 * 10 ** decimals())); // No adjustment needed

        // Marketing timelocks for 36 months
        for (uint256 i = 1; i <= 35; i++) {
            timelocks[NAWS_COLDWALLET_MARKETING].push(TimelockInfo(block.timestamp + i * month, 41666667 * 10 ** decimals()));
        }
        timelocks[NAWS_COLDWALLET_MARKETING].push(TimelockInfo(block.timestamp + 36 * month, 41666655 * 10 ** decimals())); // Adjusted to make the total 2 billion

        // Reserve timelocks for 36 months
        for (uint256 i = 1; i <= 35; i++) {
            timelocks[NAWS_COLDWALLET_RESERVE].push(TimelockInfo(block.timestamp + i * month, 55555555 * 10 ** decimals()));
        }
        timelocks[NAWS_COLDWALLET_RESERVE].push(TimelockInfo(block.timestamp + 36 * month, 55555525 * 10 ** decimals())); // Adjusted to make the total 2 billion
    }

    // Override the transfer function to include timelock checks
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
        _checkTimelocks(from, amount);
    }

    // Function to check timelocks before transferring tokens
    function _checkTimelocks(address from, uint256 amount) internal view {
        TimelockInfo[] storage locks = timelocks[from];
        uint256 lockedAmount = 0;

        for (uint256 i = 0; i < locks.length; i++) {
            if (block.timestamp < locks[i].releaseTime) {
                lockedAmount += locks[i].amount;
            }
        }

        uint256 balance = balanceOf(from);
        require(balance >= lockedAmount + amount, "Transfer amount exceeds available unlocked balance");
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
