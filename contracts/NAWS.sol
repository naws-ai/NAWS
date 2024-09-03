// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./openzeppelin-contracts-5.0.0/token/ERC20/ERC20.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "./openzeppelin-contracts-5.0.0/access/Ownable.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Permit.sol";
import "./openzeppelin-contracts-5.0.0/token/ERC20/extensions/ERC20Votes.sol";
import "./openzeppelin-contracts-5.0.0/finance/VestingWallet.sol";

contract NAWS is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {

    // Cold wallet addresses (immutable for gas optimization)
    address public immutable nawsEcosystemColdWallet;
    address public immutable nawsTeamColdWallet;
    address public immutable nawsInvestmentColdWallet;
    address public immutable nawsMarketingColdWallet;
    address public immutable nawsReserveColdWallet;

    // Vesting wallets for each category
    VestingWallet public nawsEcosystemVestingContract;
    VestingWallet public nawsTeamVestingContract;
    VestingWallet public nawsInvestmentVestingContract;
    VestingWallet public nawsMarketingVestingContract;
    VestingWallet public nawsReserveVestingContract;

    error TransferAmountExceedsUnlockedBalance(address from, uint256 requested, uint256 available);

    constructor(address initialOwner)
        ERC20("NAWS", "NAWS")
        Ownable(initialOwner)
        ERC20Permit("NAWS")
    {
        nawsEcosystemColdWallet = 0xe71277118C276Bef6F722F50F039EfD7aEe5AFAF;
        nawsTeamColdWallet = 0x40ea4678523578839DE6ABcfA74711d38FBd5132;
        nawsInvestmentColdWallet = 0xdD668C685d166b950BF3efCb53e49ED9E794976e;
        nawsMarketingColdWallet = 0x9afCD842F6dbCc63C5521E6593DCda5c670F3C4D;
        nawsReserveColdWallet = 0xa9671aA2Ee1AbBC63002053A755642C1A31D9347;

        uint256 month = 30 days;

        // Vesting wallets are created with their respective beneficiaries
        nawsEcosystemVestingContract = new VestingWallet(nawsEcosystemColdWallet, uint64(block.timestamp), uint64(month * 18));
        nawsTeamVestingContract = new VestingWallet(nawsTeamColdWallet, uint64(block.timestamp), uint64(month * 24));
        nawsInvestmentVestingContract = new VestingWallet(nawsInvestmentColdWallet, uint64(block.timestamp), uint64(month * 24));
        nawsMarketingVestingContract = new VestingWallet(nawsMarketingColdWallet, uint64(block.timestamp), uint64(month * 36));
        nawsReserveVestingContract = new VestingWallet(nawsReserveColdWallet, uint64(block.timestamp), uint64(month * 36));

        // Initial token allocation to cold wallets
        _mint(nawsEcosystemColdWallet, 1000000000 * 10 ** decimals());
        _mint(nawsTeamColdWallet, 500000000 * 10 ** decimals());
        _mint(nawsInvestmentColdWallet, 500000000 * 10 ** decimals());
        _mint(nawsMarketingColdWallet, 500000000 * 10 ** decimals());
        _mint(nawsReserveColdWallet, 0);
    }

    // Function to check timelocks before transferring tokens
    function _checkTimelocks(address from, uint256 amount) internal view {
        uint256 lockedAmount = 0;
        if (from == nawsEcosystemColdWallet) {
            lockedAmount = nawsEcosystemVestingContract.vestedAmount(address(this)) - nawsEcosystemVestingContract.released(address(this));
        } else if (from == nawsTeamColdWallet) {
            lockedAmount = nawsTeamVestingContract.vestedAmount(address(this)) - nawsTeamVestingContract.released(address(this));
        } else if (from == nawsInvestmentColdWallet) {
            lockedAmount = nawsInvestmentVestingContract.vestedAmount(address(this)) - nawsInvestmentVestingContract.released(address(this));
        } else if (from == nawsMarketingColdWallet) {
            lockedAmount = nawsMarketingVestingContract.vestedAmount(address(this)) - nawsMarketingVestingContract.released(address(this));
        } else if (from == nawsReserveColdWallet) {
            lockedAmount = nawsReserveVestingContract.vestedAmount(address(this)) - nawsReserveVestingContract.released(address(this));
        }

        uint256 available = balanceOf(from) - lockedAmount;
        if (available < amount) {
            revert TransferAmountExceedsUnlockedBalance(from, amount, available);
        }
    }

    // Function to release vested tokens to their respective cold wallets
    function releaseAllToColdWallets() external {
        nawsEcosystemVestingContract.release(address(this));
        nawsTeamVestingContract.release(address(this));
        nawsInvestmentVestingContract.release(address(this));
        nawsMarketingVestingContract.release(address(this));
        nawsReserveVestingContract.release(address(this));
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        if (from != address(0)) {
            // Only check timelocks if tokens are being transferred out
            _checkTimelocks(from, value);
        }
        super._update(from, to, value);
    }

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
