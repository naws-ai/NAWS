// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./openzeppelin-contracts-5.0.0/token/ERC20/ERC20.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "./openzeppelin-contracts-5.0.0/access/Ownable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NAWS is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes, ReentrancyGuard {
    // Cold wallet addresses (immutable for gas optimization)
    address public immutable nawsColdWalletDeploy = 0xD6c7eF117a12a2F7CfA13e8DF672D7B98dA2A46F;
    address public immutable nawsColdWalletEcosystem = 0xe71277118C276Bef6F722F50F039EfD7aEe5AFAF;
    address public immutable nawsColdWalletTeam = 0x40ea4678523578839DE6ABcfA74711d38FBd5132;
    address public immutable nawsColdWalletInvestment = 0xdD668C685d166b950BF3efCb53e49ED9E794976e;
    address public immutable nawsColdWalletMarketing = 0x9afCD842F6dbCc63C5521E6593DCda5c670F3C4D;
    address public immutable nawsColdWalletReserve = 0xa9671aA2Ee1AbBC63002053A755642C1A31D9347;

    // Constants for token distribution
    uint256 public constant TOTAL_SUPPLY = 10000000000 * 10 ** 18; // Total supply: 10 billion tokens
    uint256 public constant ALLOCATION_AMOUNT = TOTAL_SUPPLY / 5; // 20% allocation per wallet

    // Mapping for banned addresses
    mapping(address => bool) public banlist;

    // Events
    event AddressBanned(address indexed account);
    event AddressUnbanned(address indexed account);
    event ContractPaused(address account);
    event ContractUnpaused(address account);

    error AddressIsBanned(address account);

    constructor()
        ERC20("NAWS.AI", "NAWS")
        Ownable(nawsColdWalletDeploy)
        ERC20Permit("NAWS.AI")
    {
        // Validate cold wallet addresses
        require(nawsColdWalletDeploy != address(0), "Invalid deploy wallet address");
        require(nawsColdWalletEcosystem != address(0), "Invalid ecosystem wallet address");
        require(nawsColdWalletTeam != address(0), "Invalid team wallet address");
        require(nawsColdWalletInvestment != address(0), "Invalid investment wallet address");
        require(nawsColdWalletMarketing != address(0), "Invalid marketing wallet address");
        require(nawsColdWalletReserve != address(0), "Invalid reserve wallet address");

        // Token distribution
        _mint(address(this), TOTAL_SUPPLY);
        _initializeColdWallets();
    }

    function _initializeColdWallets() internal {
        // Distribute initial tokens to cold wallets
        _transfer(address(this), nawsColdWalletEcosystem, ALLOCATION_AMOUNT);
        _transfer(address(this), nawsColdWalletTeam, ALLOCATION_AMOUNT);
        _transfer(address(this), nawsColdWalletInvestment, ALLOCATION_AMOUNT);
        _transfer(address(this), nawsColdWalletMarketing, ALLOCATION_AMOUNT);
        _transfer(address(this), nawsColdWalletReserve, ALLOCATION_AMOUNT);
    }
    
    modifier notBanned(address account) {
        require(!banlist[account], "NAWS: Address is banned");
        _;
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
        whenNotPaused
        notBanned(from)
        notBanned(to)
    {
        super._update(from, to, value);
    }

    function banAddress(address account) public onlyOwner nonReentrant {
        banlist[account] = true;
        emit AddressBanned(account);
    }

    function unbanAddress(address account) public onlyOwner nonReentrant {
        banlist[account] = false;
        emit AddressUnbanned(account);
    }

    function pause() public onlyOwner {
        _pause();
        emit ContractPaused(msg.sender);
    }

    function unpause() public onlyOwner {
        _unpause();
        emit ContractUnpaused(msg.sender);
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
