const fs = require("fs");

async function deploy() {
	const factory = await hre.ethers.getContractFactory("PkYellowNft");
	const contract = await factory.deploy();
	await contract.deployed();
	console.log("Contract deployed to:", contract.address);

	fs.writeFileSync("contract-address.json", JSON.stringify(contract.address));
}

async function main() {
	try {
		await deploy();
		process.exit(0);
	} catch (error) {
		console.error(error);
		process.exit(1);
	}
}

main();
