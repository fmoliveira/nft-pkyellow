const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PkYellowNft", () => {
	let contract;
	let signers;

	beforeEach(async () => {
		const factory = await ethers.getContractFactory("PkYellowNft");
		contract = await factory.deploy();
		signers = await ethers.getSigners();
		await contract.deployed();
	});

	it("mints first token with id #1", async () => {
		await contract.mintPokemon();
		const publicIssued = await contract.getTotalIssued();
		expect(publicIssued).to.equal(1);
	});

	it("minting is capped to 2 tokens per address", async () => {
		await contract.mintPokemon();
		await contract.mintPokemon();
		const publicIssued = await contract.getTotalIssued();
		expect(publicIssued).to.equal(2);

		await expect(contract.mintPokemon()).to.be.revertedWith(
			"You have reached your minting limit.",
		);
	});

	it("minting is allowed to other accounts", async () => {
		await contract.mintPokemon();
		await contract.mintPokemon();

		const [, otherWallet] = signers;
		await contract.connect(otherWallet).mintPokemon();
		await contract.connect(otherWallet).mintPokemon();

		const publicIssued = await contract.getTotalIssued();
		expect(publicIssued);
	});

	it("finds pokemon attributes in token uri", async () => {
		await contract.mintPokemon();
		const tokenUri = await contract.tokenURI(1);

		const decodedToken = decodeTokenUri(tokenUri);
		expect(decodedToken.name).to.exist;
		expect(decodedToken.description).to.exist;
		expect(decodedToken.image).to.exist;
		expect(decodedToken.attributes).to.exist;

		const [primaryType] = decodedToken.attributes;
		expect(primaryType.trait_type).to.equal("Primary Type");
		expect(primaryType.value).to.exist;

		const [level] = decodedToken.traits;
		expect(level.trait_type).to.equal("Level");
		expect(level.value).to.exist;
	});
});

function decodeTokenUri(tokenUri) {
	const [, payload] = tokenUri.split(",");
	const decoded = Buffer.from(payload, "base64").toString();
	return JSON.parse(decoded);
}
