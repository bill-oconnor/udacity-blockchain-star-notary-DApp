pragma solidity 0.5.17;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; // this is key!
    mapping(uint256 => uint256) public starsForSale;

    function createStar(string _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender);
        starsForSale[_tokenId] = _price;
    }

    // pay attention to how this works!
    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");

        transferFrom(starOwner, msg.sender, _tokenId);

        starOwner.transfer(starCost);

        if (msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }

        starsForSale[_tokenId] = 0;
    }
}
