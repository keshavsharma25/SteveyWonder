// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC6551Account } from "erc6551/interfaces/IERC6551Account.sol";
import { ERC6551AccountLib } from "erc6551/lib/ERC6551AccountLib.sol";
import { SteveyWonder } from "../SteveyWonder.sol";

contract Glasses is ERC721, ERC721Burnable, Ownable, ERC721Enumerable {
	uint256 private _nextTokenId = 1;

	address private _steveyWonderAddr;
	address private _erc6551RegistryAddr;
	address private _accImplementationAddr;
	bytes32 private immutable _salt = bytes32(0);

	constructor(
		address _initialOwner,
		address _steveyWonder,
		address _erc6551Registry,
		address _accImplementation
	) ERC721("Glasses", "SHOE") Ownable(_initialOwner) {
		_steveyWonderAddr = _steveyWonder;
		_erc6551RegistryAddr = _erc6551Registry;
		_accImplementationAddr = _accImplementation;
	}

	function safeMint(uint256 _toTokenId) public payable {
		uint256 tokenId = _nextTokenId++;

		address to = IERC6551Registry(_erc6551RegistryAddr).account(
			_accImplementationAddr,
			_salt,
			block.chainid,
			_steveyWonderAddr,
			_toTokenId
		);

		_safeMint(to, tokenId);
	}

	function _GlassesURI(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder Glasses #',
								Strings.toString(_tokenId),
								'", "image": "',
								_generateBase64(_tokenId),
								unicode'", "description": "This is an Inventory NFT item that can be traded or bought to make your SteveyWonder look awesome!",',
								unicode'"attributes: [{"trait_type": "type", "value": "glasses"}]}'
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
				'<svg xmlns="http://www.w3.org/2000/svg"  width="400" height="400" viewBox="0 0 400 400" fill="none">',
				renderByTokenId(_tokenId),
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		return _glassesSVG(_tokenId);
	}

	function _glassesSVG(uint256 _tokenId) public view returns (string memory) {
		uint256 salt = uint256(uint(_salt));

		return
			string.concat(
				'<rect id="',
				Strings.toString(salt + _tokenId),
				'" x="170" y="70" width="23" height="22" rx="1" fill="black" fill-opacity="0.8" stroke="black" stroke-width="2"/>',
				'<rect x="207" y="70" width="23" height="22" rx="1" fill="black" fill-opacity="0.8" stroke="black" stroke-width="2"/>',
				'<line x1="192" y1="81" x2="207" y2="81" stroke="black" stroke-width="2"/>',
				'<line x1="169.629" y1="80.9285" x2="159.629" y2="76.9285" stroke="black" stroke-width="2"/>',
				'<line y1="-1" x2="10.7703" y2="-1" transform="matrix(0.928477 -0.371391 -0.371391 -0.928477 230 80)" stroke="black" stroke-width="2"/>'
			);
	}

	/* --------------------------- override functions --------------------------- */

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		return _GlassesURI(tokenId);
	}

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		address previousOwner = super._update(to, tokenId, auth);

		bool isErc6551Acc = ERC6551AccountLib.isERC6551Account(
			previousOwner,
			_accImplementationAddr,
			_erc6551RegistryAddr
		);

		if (isErc6551Acc) {
			(, , uint256 steveyWonderTokenId) = IERC6551Account(
				payable(previousOwner)
			).token();

			SteveyWonder steveyWonder = SteveyWonder(
				payable(_steveyWonderAddr)
			);

			if (
				tokenId ==
				steveyWonder.getActiveAccessory(
					address(this),
					steveyWonderTokenId
				)
			) {
				if (balanceOf(previousOwner) > 0) {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						tokenOfOwnerByIndex(previousOwner, 0)
					);
				} else {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						0
					);
				}
			}
		}
		return previousOwner;
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}
}
