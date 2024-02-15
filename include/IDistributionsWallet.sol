pragma ton-solidity >= 0.58.1;

interface IDistributionsWallet {
    event WithdrawDistributedTokens(address property, address unit, address recipient, uint128 amount);
    function unitAddress(uint256 id) external view responsible returns (address unit);
    function getInfo() external responsible returns(address property,address unitRoot,address tip3TokenRoot,address tip3Wallet,uint128 numOfUnits,uint128 unitReward,uint128 undistributedBalance);
    function transfer(uint256 id,uint128 withdrawnAmt,uint128 pendingAmt,address to,address sendGasTo) external;
}
