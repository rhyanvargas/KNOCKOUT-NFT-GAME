async function main() {

  // Compile contract to generate abi and bytecode - Inside artifacts folder
  const gameContractFactory = await hre.ethers.getContractFactory('NftGame');
  
  // Create local Ethereum blockchain
  const gameContract = await gameContractFactory.deploy(
    ["Mike Tyson", "Piston Honda", "Mr. Sandman", "Soda Popinksi", "Super Macho Man", "Von Kaiser"], // Names
    [
      "https://charactersdb.com/wp-content/uploads/mike-tyson-punch-out-1.jpg",
      "https://charactersdb.com/wp-content/uploads/piston-honda-punch-out.jpg",
      "https://charactersdb.com/wp-content/uploads/mr.sandman-punch-out.jpg",
      "https://charactersdb.com/wp-content/uploads/soda-popinski-punch-out.jpg",
      "https://charactersdb.com/wp-content/uploads/super-macho-man-punch-out.jpg",
      "https://charactersdb.com/wp-content/uploads/von-kaiser-punch-out-nes.jpg"
    ], // images
    [1000,900,700,600,500,400], // HP
    [90,30,50,60,70,80], // Attack
    [300,80,100,120,150,200] // Power Attack
  );

  gameContract.deployed();
  console.log("CONTRACT DEPLOYED TO: ", gameContract.address)

  for(let i=0;i<4;i++){
    // Mint multiple NFTS
    let txn;
    txn = await gameContract.mintCharacter(i);
    await txn.wait();
    
    // Get me the NFT Data
    let returnedTokenURI = await gameContract.tokenURI(1);
    console.log("\n=========Token URI:", returnedTokenURI);
  }


}


const runMain = async() => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    process.exit(1);
  }
}

runMain();