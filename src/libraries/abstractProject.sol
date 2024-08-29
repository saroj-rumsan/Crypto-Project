pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

import "../interfaces/IRahatProject.sol";

abstract contract AbstractProject is Multicall, IRahatProject {
    using EnumerableSet for EnumerableSet.AddressSet;

    event BeneficiaryAdded(address indexed);
    event BeneficiaryRemoved(address indexed);

    event TokenRegistered(address indexed tokenAddress);
    event TokenBudgetIncrease(address indexed tokenAddress, uint amount);
    event TokenBudgetDecrease(address indexed tokenAddress, uint amount);
    event TokenReceived(
        address indexed token,
        address indexed from,
        uint amount
    );
    event TokenTransfer(address indexed token, address indexed to, uint amount);
    // #endregion

    // #region ***** Variables *********//
    mapping(address => uint) private _tokenBudget;
    mapping(address => bool) private _registeredTokens;

    string public override name;

    EnumerableSet.AddressSet internal _beneficiaries;

    // #endregion

    constructor(string memory _name) {
        name = _name;
    }

    // #endregion

    // #region ***** Beneficiary Functions *********//
    function isBeneficiary(
        address _address
    ) public view virtual returns (bool) {
        return _beneficiaries.contains(_address);
    }

    function beneficiaryCount() public view virtual returns (uint256) {
        return _beneficiaries.length();
    }

    function _addBeneficiary(address _address) internal {
        if (!_beneficiaries.contains(_address)) emit BeneficiaryAdded(_address);
        _beneficiaries.add(_address);
    }

    function _removeBeneficiary(address _address) internal {
        if (_beneficiaries.contains(_address))
            emit BeneficiaryRemoved(_address);
        _beneficiaries.remove(_address);
    }

    // #endregion

    // #region ***** Token Functions *********//
    function tokenBudget(
        address _tokenAddress
    ) public view virtual returns (uint) {
        return _tokenBudget[_tokenAddress];
    }

    function _tokenBudgetIncrease(
        address _tokenAddress,
        uint _amount
    ) internal {
        _tokenBudget[_tokenAddress] += _amount;
        emit TokenBudgetIncrease(_tokenAddress, _amount);

        if (!_registeredTokens[_tokenAddress]) {
            _registeredTokens[_tokenAddress] = true;
            emit TokenRegistered(_tokenAddress);
        }
    }

    function _tokenBudgetDecrease(
        address _tokenAddress,
        uint _amount
    ) internal {
        _tokenBudget[_tokenAddress] -= _amount;
        emit TokenBudgetDecrease(_tokenAddress, _amount);
    }

    function _acceptToken(
        address _tokenAddress,
        address _from,
        uint256 _amount
    ) internal {
        IERC20(_tokenAddress).transferFrom(_from, address(this), _amount);
        _tokenBudgetIncrease(_tokenAddress, _amount);
        emit TokenReceived(_tokenAddress, _from, _amount);
    }

    function _withdrawToken(
        address _tokenAddress,
        uint _amount,
        address _withdrawAddress
    ) internal {
        _tokenBudgetDecrease(_tokenAddress, _amount);

        emit TokenTransfer(_tokenAddress, address(_withdrawAddress), _amount);
    }
}
