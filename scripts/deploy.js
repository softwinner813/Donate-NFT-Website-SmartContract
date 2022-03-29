const { utils } = require("ethers");

async function main() {
    const baseTokenURI = "ipfs://QmP5ZS2svnqPeiRh1U4b9XNcuEbZoM8kVhEcDhZh6umht3/";
    const urls = [
        "https://gateway.pinata.cloud/ipfs/QmPVCeWtQxnDyxjdi7PHcHaK2rBDZbBgWUy6LN5AuoTTCu",
        "https://gateway.pinata.cloud/ipfs/QmSKm8vPFYn2hYQKLNxGqPz87KRQ56LQqFtEcQEYJXimHt",
        "https://gateway.pinata.cloud/ipfs/Qmco4H9p1e62ssfm94GaQe832Nfjy6NdudQSHmnQz6vh45"
    ];

    // Get owner/deployer's wallet address
    const [owner] = await hre.ethers.getSigners();

    // Get contract that we want to deploy
    const contractFactory = await hre.ethers.getContractFactory("PEACE2UKRAINE");

    // Deploy contract with the correct constructor arguments
    // const contract = await contractFactory.deploy(baseTokenURI);
    const contract = await contractFactory.deploy();

    // Wait for this transaction to be mined
    await contract.deployed();

    // Get contract address
    console.log("Contract deployed to:", contract.address);

    // // Reserve NFTs
    // let txn = await contract.reserveNFTs();
    // await txn.wait();
    // console.log("10 NFTs have been reserved");

    // // Mint 3 NFTs by sending 0.03 ether
    // txn = await contract.mintNFTs(3, { value: utils.parseEther('0.001') });
    // await txn.wait()
    for (let i = 0; i < urls.length; i++) {
        const url = urls[i];

        let txn = await contract.mintSingleNFT(url) 
        await txn.wait()
    }
    
    
    // Get all token IDs of the owner
    let tokens = await contract.tokensOfOwner(owner.address)
    console.log("Owner has tokens: ", tokens);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });