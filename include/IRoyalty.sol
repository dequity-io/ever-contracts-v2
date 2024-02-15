pragma ton-solidity >= 0.58.1;

interface IRoyalty {
    function getRoyaltyInfo() external view responsible returns(uint8 royalty, address receiver);
}
