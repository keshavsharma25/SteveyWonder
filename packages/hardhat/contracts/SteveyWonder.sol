//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC4906 } from "./interfaces/IERC4906.sol";
import { IERC721Custom } from "./interfaces/IERC721Custom.sol";

/**
 * @title SteveyWonder
 * @author Keshav
 * @notice A simple ERC721 contract that mints Stevey NFTs that are converted to
 * ERC6551 tokens.
 * @dev This contract is designed to be used with the ERC6551Registry and Account Proxy contract.
 */
contract SteveyWonder is
	ERC721,
	ERC721Burnable,
	ERC721Enumerable,
	Ownable,
	IERC4906
{
	/* ----------------------------- State Variables ---------------------------- */
	address public immutable _erc6551Registry;
	address public immutable _accImplementation;
	bytes32 public immutable salt = bytes32(0);

	uint256 private _nextTokenId = 1;
	uint256 private price;
	address[] public nftAccessoryAddrs;
	mapping(address => bool) public hasNftAccessoryAddrs;

	mapping(address => mapping(uint256 => uint256)) public activeAccessories;

	/* ------------------------------- Constructor ------------------------------ */
	constructor(
		address _initialOwner,
		address _erc6551RegistryAddr,
		address _accImplementationAddr
	) ERC721("Stevey", "STEV") Ownable(_initialOwner) {
		_erc6551Registry = _erc6551RegistryAddr;
		_accImplementation = _accImplementationAddr;
	}

	/* -------------------------------- Functions ------------------------------- */
	function safeMint() public payable returns (address) {
		uint256 tokenId = _nextTokenId++;
		_safeMint(msg.sender, tokenId);

		address tba = IERC6551Registry(_erc6551Registry).createAccount(
			_accImplementation,
			bytes32(0),
			block.chainid,
			address(this),
			tokenId
		);

		return tba;
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder", "description": "This is a collection of SteveyWonder NFTs.", "image": "',
			'", "external_link": "https://steveywonder.vercel.app/",',
			'"collaborators": [""]'
			'"}'
		);

		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(bytes(json))
				)
			);
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		require(tokenId < _nextTokenId, "Token ID does not exist");
		return _steveyWonderTokenURI(tokenId);
	}

	function _steveyWonderTokenURI(
		uint256 tokenId
	) internal view returns (string memory) {
		string memory svg = _generateBase64(tokenId);
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder", "image": "',
								svg,
								'", "description": "This is a Character NFT',
								" based on the implementation of ERC6551 and its application.",
								' This NFT account contains other accessories as NFTs."}'
							)
						)
					)
				)
			);
	}

	function _generateBase64(
		uint256 _tokenId
	) internal view returns (string memory) {
		return Base64.encode(bytes(_generateSVG(_tokenId)));
	}

	function _generateSVG(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string.concat(
				'<svg width="472" height="472" viewBox="0 0 472 472" fill="none" xmlns="http://www.w3.org/2000/svg">',
				renderByTokenId(_tokenId),
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) internal view returns (string memory) {
		string memory render = SteveyWonderSvg();

		for (uint256 i = 0; i < nftAccessoryAddrs.length; i++) {
			if (activeAccessories[nftAccessoryAddrs[i]][_tokenId] > 0) {
				render = string.concat(
					render,
					renderAccessory(nftAccessoryAddrs[i], _tokenId)
				);
			}
		}

		return render;
	}

	function renderAccessory(
		address nftAccessory,
		uint256 _tokenId
	) internal view returns (string memory) {
		return IERC721Custom(nftAccessory).renderByTokenId(_tokenId);
	}

	function SteveyWonderSvg() internal pure returns (string memory) {
		return
			string.concat(
				'<rect width="40" height="119.909" transform="matrix(1 0 0 -1 212 382.103)" fill="#EFA78C"/>',
				'<path d="M148 382.103H188V262.194H148V382.103Z" fill="#EFA78C"/>',
				'<rect width="40" height="129.737" transform="matrix(1 0 0 -1 258 257.28)" fill="#EFA78C"/>',
				'<rect width="40" height="129.737" transform="matrix(1 0 0 -1 102 257.28)" fill="#EFA78C"/>',
				'<rect x="142" y="127.543" width="116" height="135.634" fill="#E89B7F"/>',
				'<rect x="160" y="56.7769" width="80.0007" height="70.7663" fill="#EFA78C"/>',
				'<rect x="173" y="72.5029" width="16.0004" height="15.7261" fill="white"/>',
				'<rect x="179" y="75.4512" width="10.0003" height="9.82882" fill="black"/>',
				'<rect x="188" y="105.92" width="24.0006" height="9.82882" fill="#BB7156"/>',
				'<rect x="210.998" y="72.5029" width="16.0004" height="15.7261" fill="white"/>',
				'<rect x="210.998" y="75.4512" width="10.0003" height="9.82882" fill="black"/>',
				'<path d="M258 263.177H142V312.32H197V301.509H203V312.32H258V263.177Z" fill="white"/>'
			);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(IERC165, ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}

	function addNftAccessoryAddr(address _nftAccessory) public onlyOwner {
		if (!hasNftAccessoryAddrs[_nftAccessory]) {
			nftAccessoryAddrs.push(_nftAccessory);
			hasNftAccessoryAddrs[_nftAccessory] = true;
		}
	}

	function setActiveAccessories(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) public {
		require(
			ownerOf(_SteveyWondertokenId) == msg.sender,
			"only token owner can set accessory"
		);
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		IERC721 nftAccessory = IERC721(_nftAccessory);

		require(
			nftAccessory.ownerOf(_accessoryTokenId) ==
				getTBAAddress(_SteveyWondertokenId),
			"only accessories that belong to the Token Bound Account can be set."
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function setActiveAccessoriesOnUpdate(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) public {
		require(
			_nftAccessory == msg.sender,
			"only nft accessory address can set accessory"
		);

		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function getActiveAccessory(
		address _nftAccessory,
		uint256 _SteveyWondertokenId
	) public view returns (uint256) {
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"invalid NFT Accessory address"
		);
		return activeAccessories[_nftAccessory][_SteveyWondertokenId];
	}

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		return super._update(to, tokenId, auth);
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function getTBAAddress(uint256 tokenId) public view returns (address) {
		return
			IERC6551Registry(_erc6551Registry).account(
				_accImplementation,
				salt,
				block.chainid,
				address(this),
				tokenId
			);
	}

	/* --------------------------------- receive -------------------------------- */
	receive() external payable {}
}
