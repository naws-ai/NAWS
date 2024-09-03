// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./openzeppelin-contracts-5.0.0/token/ERC20/ERC20.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "./openzeppelin-contracts-5.0.0/access/Ownable.sol"; // Updated Ownable contract
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Votes.sol";
import "./openzeppelin-contracts-5.0.0/finance/VestingWallet.sol";

contract NAWS is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {
    // Cold wallet addresses (immutable for gas optimization)
    address public immutable nawsColdWalletDeploy = 0x0E8612586c277e1ca343B9B653bb916B141B8081;
    address public immutable nawsColdWalletEcosystem = 0xe71277118C276Bef6F722F50F039EfD7aEe5AFAF;
    address public immutable nawsColdWalletTeam = 0x40ea4678523578839DE6ABcfA74711d38FBd5132;
    address public immutable nawsColdWalletInvestment = 0xdD668C685d166b950BF3efCb53e49ED9E794976e;
    address public immutable nawsColdWalletMarketing = 0x9afCD842F6dbCc63C5521E6593DCda5c670F3C4D;
    address public immutable nawsColdWalletReserve = 0xa9671aA2Ee1AbBC63002053A755642C1A31D9347;

    // Vesting wallets for each category
    VestingWallet public ecosystemVestingContractWallet;
    VestingWallet public teamVestingContractWallet;
    VestingWallet public investmentVestingContractWallet;
    VestingWallet public marketingVestingContractWallet;
    VestingWallet public reserveVestingContractWallet;

    // Mapping for banned addresses
    mapping(address => bool) public banlist;

    // Events for banning and unbanning addresses
    event AddressBanned(address indexed account);
    event AddressUnbanned(address indexed account);

    error AddressIsBanned(address account);

    constructor()
    ERC20("NAWS", "NAWS")
    Ownable(nawsColdWalletDeploy) // Use the new constructor for Ownable
    ERC20Permit("NAWS")
    {
        uint256 month = 30 days;
        uint256 totalSupply = 10000000000 * 10 ** decimals(); // Total supply: 10 billion tokens

        // Vesting wallets are created with their respective beneficiaries
        // Vesting starts based on TGE (Token Generation Event)
        ecosystemVestingContractWallet = new VestingWallet(nawsColdWalletEcosystem, uint64(block.timestamp), uint64(month * 18)); // 18 months vesting
        teamVestingContractWallet = new VestingWallet(nawsColdWalletTeam, uint64(block.timestamp), uint64(month * 24)); // 24 months vesting
        investmentVestingContractWallet = new VestingWallet(nawsColdWalletInvestment, uint64(block.timestamp), uint64(month * 24)); // 24 months vesting
        marketingVestingContractWallet = new VestingWallet(nawsColdWalletMarketing, uint64(block.timestamp), uint64(month * 36)); // 36 months vesting
        reserveVestingContractWallet = new VestingWallet(nawsColdWalletReserve, uint64(block.timestamp), uint64(month * 36)); // 36 months vesting

        // Calculate 20% of total supply for each wallet
        uint256 allocationAmount = totalSupply / 5; // 20% allocation per wallet (2 billion tokens each)

        // Initial token allocation to cold wallets
        _mint(nawsColdWalletEcosystem, allocationAmount / 2); // Immediate release of 1 billion tokens to Ecosystem cold wallet
        _mint(nawsColdWalletTeam, allocationAmount / 4); // Immediate release of 500 million tokens to Team cold wallet
        _mint(nawsColdWalletInvestment, allocationAmount / 4); // Immediate release of 500 million tokens to Investment cold wallet
        _mint(nawsColdWalletMarketing, allocationAmount / 4); // Immediate release of 500 million tokens to Marketing cold wallet
        // Reserve wallet initial allocation is 0 tokens to the cold wallet

        // Vesting wallet allocation for the locked amounts
        _mint(address(ecosystemVestingContractWallet), allocationAmount / 2); // 1 billion tokens to Ecosystem vesting contract wallet
        _mint(address(teamVestingContractWallet), allocationAmount * 3 / 4); // 1.5 billion tokens to Team vesting contract wallet
        _mint(address(investmentVestingContractWallet), allocationAmount * 3 / 4); // 1.5 billion tokens to Investment vesting contract wallet
        _mint(address(marketingVestingContractWallet), allocationAmount * 3 / 4); // 1.5 billion tokens to Marketing vesting contract wallet
        _mint(address(reserveVestingContractWallet), allocationAmount); // 2 billion tokens to Reserve vesting contract wallet
    }

    // Modifier to check if an address is banned
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

    // Functions to ban and unban addresses
    function banAddress(address account) public onlyOwner {
        banlist[account] = true;
        emit AddressBanned(account);
    }

    function unbanAddress(address account) public onlyOwner {
        banlist[account] = false;
        emit AddressUnbanned(account);
    }

    // Pausing and unpausing contract functions
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
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
