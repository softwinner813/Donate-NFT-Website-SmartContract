/******************************
 * @Auth: Geniusdev0813
 * @Date: 2022.3.22
 * @Desc: Peace2Ukraine NFT Smart Contract
 */


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PEACE2UKRAINE is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    // Count of Total NFT (Token)
    Counters.Counter private _tokenIds;

    // Total NFT Supply
    uint public constant MAX_SUPPLY = 1000;

    // Mint Price for each NFT 
    uint public constant PRICE = 0.0001 ether;

    // Limit per Mint
    uint public constant MAX_PER_MINT = 10;
    
    // Pinata Metadata URI for Opensea marketplace
    string public baseTokenURI;
    
    // Percent of Donate for Ukraine
    uint public donateRate = 20;
    
    /***************************** Functions *********************************/

    constructor (string memory baseURI) ERC721("Peace 2 Ukraine", "PEACE2UKRAINE") {
        setBaseURI(baseURI);
    }

    constructor () ERC721("Peace 2 Ukraine", "PEACE2UKRAINE") {
    }
    
    // Get Donate Rate
    function _donateRate() internal view virtual override returns (uint memory) {
        return donateRate;
    }

    // Set Donate Rate
    function setDonateRate(uint _donateRate) public onlyOwner {
        donateRate = _donateRate;
    }

    // Get BaseURI for IPFS (Pinata)
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // Set BaseURI for IPFS (Pinata)
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }
    
    // Get total NFT count
    function _lastTokenID() internal view virtual override returns (uint memory) {
        return _tokenIds.current();
    }

        
    // Reserve 10 NFT only Owner
    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(10) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }
    

    // Multi Mint only Onwer
    function mintNFTs(uint _count, string memory _baseTokenURI) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs. You can mint at most 10 NFT at once");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }

        setBaseURI(_baseTokenURI);
    }
    
    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    // Single Mint only Onwer
    function mintSingleNFT(string memory _baseTokenURI) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(1) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(msg.value >= PRICE, "Not enough ether to purchase NFT.");

        _mintSingleNFT();

        setBaseURI(_baseTokenURI);
    }
    
    
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
    
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function donate() private {
        uint balance = address(this).balance;
        uint donateAmount = balance.mul(donateRate).div(100);
        return donateAmount;
    }
}