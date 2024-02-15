pragma ton-solidity >= 0.58.1;

interface IProperty  {
    function getDistrWallet() external view responsible returns(address distrWallet);
    function getUnitRoot() external view responsible returns(address unitRoot);
}
