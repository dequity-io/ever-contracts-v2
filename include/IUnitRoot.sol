pragma ton-solidity >= 0.58.1;

uint16 constant RETAIL_CUTOFF = 7;

interface IUnitRoot {
    function getInfo() external responsible returns(address property,address distrWallet);
}
