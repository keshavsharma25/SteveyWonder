// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import { IERC721 } from "@openzeppelin/contracts/interfaces/IERC721.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC6551Account } from "erc6551/interfaces/IERC6551Account.sol";
import { IERC6551Executable } from "erc6551/interfaces/IERC6551Executable.sol";
import { ERC6551AccountLib } from "erc6551/lib/ERC6551AccountLib.sol";

contract Account is
	ERC165,
	IERC1271,
	IERC6551Account,
	IERC6551Executable,
	ERC721Holder,
	ERC1155Holder
{
	/* --------------------------------- errors --------------------------------- */
	error NotAuthorized();

	/* -------------------------------- modifiers ------------------------------- */
	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	/* ----------------------------- state variables ---------------------------- */
	uint256 public state;

	/* --------------------------- internal functions --------------------------- */
	function _checkOwner() internal view virtual {
		(uint256 chainId, address tokenContract, uint256 tokenId) = token();

		address _owner = _tokenOwner(chainId, tokenContract, tokenId);
		if (msg.sender != _owner) revert NotAuthorized();
	}

	function _tokenOwner(
		uint256 chainId,
		address tokenContract,
		uint256 tokenId
	) internal view virtual returns (address) {
		if (chainId != block.chainid) return address(0);
		if (tokenContract.code.length == 0) return address(0);

		try IERC721(tokenContract).ownerOf(tokenId) returns (address _owner) {
			return _owner;
		} catch {
			return address(0);
		}
	}

	function execute(
		address to,
		uint256 value,
		bytes calldata data,
		uint8 operation
	) external payable virtual returns (bytes memory result) {
		require(_isValidSigner(msg.sender), "Invalid signer");
		require(operation == 0, "Only call operations are supported");

		++state;

		bool success;
		(success, result) = to.call{ value: value }(data);

		if (!success) {
			assembly {
				revert(add(result, 32), mload(result))
			}
		}
	}

	function isValidSigner(
		address signer,
		bytes calldata
	) external view virtual returns (bytes4) {
		if (_isValidSigner(signer)) {
			return IERC6551Account.isValidSigner.selector;
		}

		return bytes4(0);
	}

	function isValidSignature(
		bytes32 hash,
		bytes memory signature
	) external view virtual returns (bytes4 magicValue) {
		bool isValid = SignatureChecker.isValidSignatureNow(
			owner(),
			hash,
			signature
		);

		if (isValid) {
			return IERC1271.isValidSignature.selector;
		}

		return bytes4(0);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public pure override(ERC165, ERC1155Holder) returns (bool) {
		return
			interfaceId == type(ERC165).interfaceId ||
			interfaceId == type(IERC6551Account).interfaceId ||
			interfaceId == type(ERC1155Holder).interfaceId ||
			interfaceId == type(IERC6551Executable).interfaceId;
	}

	function token() public view virtual returns (uint256, address, uint256) {
		return ERC6551AccountLib.token();
	}

	function owner() public view virtual returns (address) {
		(uint256 chainId, address tokenContract, uint256 tokenId) = token();
		if (chainId != block.chainid) return address(0);

		return IERC721(tokenContract).ownerOf(tokenId);
	}

	function _isValidSigner(
		address signer
	) internal view virtual returns (bool) {
		return signer == owner();
	}

	function _call(
		address to,
		uint256 value,
		bytes calldata data
	) internal returns (bytes memory result) {
		bool success;
		(success, result) = to.call{ value: value }(data);

		if (!success) {
			assembly {
				revert(add(result, 32), mload(result))
			}
		}
	}

	function transferERC721Tokens(
		address tokenCollection,
		address to,
		uint256 tokenId
	) external onlyOwner {
		IERC721 nftContract = IERC721(tokenCollection);

		require(
			nftContract.ownerOf(tokenId) == address(this),
			"NFTHandler: Sender is not the owner"
		);

		nftContract.safeTransferFrom(address(this), to, tokenId);
	}

	// Approve spender for your nft
	function ApproveERC721Tokens(
		address tokenCollection,
		address spender,
		uint256 tokenId
	) external onlyOwner {
		IERC721 nftContract = IERC721(tokenCollection);

		require(
			nftContract.ownerOf(tokenId) == address(this),
			"NFTHandler: Sender is not the owner"
		);

		nftContract.approve(spender, tokenId);
	}

	function transferERC721TokensFrom(
		address tokenCollection,
		address from,
		address to,
		uint256 tokenId
	) external onlyOwner {
		IERC721 nftContract = IERC721(tokenCollection);

		require(
			nftContract.getApproved(tokenId) == address(this),
			"NFTHandler: Sender is not approved"
		);

		nftContract.safeTransferFrom(from, to, tokenId);
	}

	/* --------------------------------- receive -------------------------------- */
	receive() external payable {}
}
