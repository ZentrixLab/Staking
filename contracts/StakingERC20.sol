pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingERC20 {
    IERC20 public token;

    uint256 rewardRate;

    // mapping address to amount staked
    mapping(address => uint256) public amountStaked;

    mapping(address => uint256) public tokenStakedAt;

    uint256 public EMISSION_RATE = (50 * 10 ** decimals()) / 1 days;

    constructor(address _token, uint256 _rewardRate) {
        token = IERC20(_token);
        rewardRate = _rewardRate;
    }

    // transfer must be approved beforehand
    function stake(uint256 _amount) external {
        amountStaked[msg.sender] = _amount;
        tokenStakedAt[msg.sender] = block.timestamp;
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Error: transfer failed");
    }

    function unstake() external {
        uint256 amount = amountStaked[msg.sender];
        require(amount > 0, "Error: no tokens staked");
        uint256 reward = getReward(msg.sender);
        delete amountStaked[msg.sender];
        delete tokenStakedAt[msg.sender];
        token.transfer(msg.sender, amount + reward);
    }

    function getReward(address _usr) internal returns(uint256) {
        uint256 timePassed = block.timestamp - tokenStakedAt[_usr];
        return rewardRate * timePassed;
    }
}