/**
 *Submitted for verification at opbnb.bscscan.com on 2025-04-22
*/

// Sources flattened with hardhat v2.22.5 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/SIS.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SignInSystem is Ownable {
    // using SafeMath for uint256;

    constructor(uint192 initRequiredSignInFee) Ownable(msg.sender) {
        sys.requiredSignGap = 1 days - 1 hours;
        sys.requiredSignInFee = initRequiredSignInFee;
    }

    // ----------------------------------------------- VARIABLES -----------------------------------------------
    struct Signer {
        uint64 totalSignInCount;
        uint192 totalSignInAmount;
        uint96 lastSignInTimestamp;
        uint160 notUse;
    }

    struct System {
        uint64 requiredSignGap;
        uint192 requiredSignInFee;
        uint64 totalSignInCount;
        uint192 totalSignInAmount;
    }

    System private sys;
    mapping(address => Signer) private Signers;

    // ----------------------------------------------- EVENT -----------------------------------------------
    event SignIn(
        address indexed player,
        uint192 signInAmount,
        uint256 signTimestamp,
        string signInMessage
    );

    event FundsFetched(address receiver, uint256 amount);

    // ----------------------------------------------- MODIFIER -----------------------------------------------
    modifier checkGap() {
        require(
            block.timestamp - Signers[msg.sender].lastSignInTimestamp >=
                sys.requiredSignGap,
            "SIS: Sign-in gap too short"
        );
        _;
    }

    // ----------------------------------------------- OWNER -----------------------------------------------

    function fetchFunds(address receiver, uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "SIS: Insufficient balance");
        payable(receiver).transfer(amount);
        emit FundsFetched(receiver, amount);
    }

    function fetchAllFunds(address receiver) external onlyOwner {
        uint256 totalFunds = address(this).balance;
        fetchFunds(receiver, totalFunds);
    }

    function updateRequiredSignGap(uint64 newGap) external onlyOwner {
        sys.requiredSignGap = newGap;
    }

    function updateRequiredSignInFee(uint192 newFee) external onlyOwner {
        sys.requiredSignInFee = newFee;
    }

    // ----------------------------------------------- USER -----------------------------------------------

    function signIn(string calldata signInMessage) external payable checkGap {
        uint192 signInFee = uint192(msg.value);
        require(signInFee >= sys.requiredSignInFee, "SIS: Insufficient fee");

        Signer storage _Signer = Signers[msg.sender];
        _Signer.totalSignInCount += 1;
        sys.totalSignInCount += 1;
        _Signer.totalSignInAmount += signInFee;
        sys.totalSignInAmount += signInFee;
        _Signer.lastSignInTimestamp = uint96(block.timestamp);

        emit SignIn(
            msg.sender,
            uint192(signInFee),
            block.timestamp,
            signInMessage
        );
    }

    // ----------------------------------------------- VIEW -----------------------------------------------
    function getSignerInfo(address signer) public view returns (Signer memory) {
        return Signers[signer];
    }

    function getSystemInfo() public view returns (System memory) {
        return sys;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
} 
// 2025-10-24 by Aven
// 0x8fc0178e07310bf081897c7d9625b8180e7c5cef
