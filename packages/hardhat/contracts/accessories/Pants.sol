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

contract Pants is ERC721, ERC721Burnable, Ownable, ERC721Enumerable {
	uint256 private _nextTokenId = 1;
	string[5] private colors = [
		"#F1EBD4",
		"#252532",
		"#141415",
		"#4F3EE0",
		"#84483B"
	];

	address private _steveyWonderAddr;
	address private _erc6551RegistryAddr;
	address private _accImplementationAddr;
	bytes32 private immutable _salt = bytes32(0);

	struct PantsColor {
		uint256 colorIndex;
	}

	mapping(uint256 => PantsColor) private _pantsColor;

	constructor(
		address _initialOwner,
		address _steveyWonder,
		address _erc6551Registry,
		address _accImplementation
	) ERC721("Pants", "PNTS") Ownable(_initialOwner) {
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

		bytes32 predictableRandom = keccak256(
			abi.encodePacked(
				tokenId,
				blockhash(block.number - 1),
				block.timestamp,
				msg.sender,
				address(this)
			)
		);

		_pantsColor[tokenId].colorIndex =
			uint256(uint8(predictableRandom[0])) %
			5;
	}

	function _pantsURI(uint256 _tokenId) internal view returns (string memory) {
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder Pants #',
								Strings.toString(_tokenId),
								'", "image": "',
								_generateBase64(_tokenId),
								'", "description": "This is an Inventory NFT item that can be traded or bought to make your SteveyWonder look awesome!",',
								'"attributes": [{"trait_type": "type", "value": "half-Pants"}, {"trait_type": "color", "value": "',
								colors[_pantsColor[_tokenId].colorIndex],
								'"}]}'
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
				'<rect id="',
				Strings.toString(_tokenId),
				'" width="400" height="400" fill="',
				colors[_pantsColor[_tokenId].colorIndex],
				'" fill-opacity="0.1"/>',
				'<g transform="translate(-200,-400) scale(2, 2)">',
				renderByTokenId(_tokenId),
				"</g>",
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		return _pantsSVG(_tokenId);
	}

	function _pantsSVG(uint256 _tokenId) public view returns (string memory) {
		return
			string.concat(
				'<path fill-rule="evenodd" clip-rule="evenodd" d="M298.492 300.044H174.004V324.303V359.111V420.288H229.809V359.111H242.687V420.288H298.492V324.303H298.492V300.044Z" fill="',
				colors[_pantsColor[_tokenId].colorIndex],
				'"/>'
			);
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder\'s Pants Collection", "description": "This is a collection of SteveyWonder\'s Pants NFTs.", "image": "',
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

	/* --------------------------- override functions --------------------------- */

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		return _pantsURI(tokenId);
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
