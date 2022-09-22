const Lottery = artifacts.require("Lottery")
const { LinkToken } = require("@chainlink/contracts/truffle/v0.4/LinkToken")

module.exports = async function (deployer, network, [defaultAccount]) {
    if (!network.startsWith("georli")) {
        console.log("Currently only works with Goerli!")
        LinkToken.setProvider(deployer.provider)
    } else {
        const GOERLI_KEYHASH = "0x0476f9a745b61ea5c0ab224d3a6e4c99f0b02fce4da01143a4f70aa80ae76e8a"
        const GOERLI_VRF_COORDINATOR = "0x2bce784e69d2Ff36c71edcB9F88358dB0DfB55b4"
        const GOERLI_ETH_USD_PRICE_FEED = "0xA39434A63A52E749F02807ae27335515BA4b07F7"
        const GOERLI_LINK_TOKEN = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
        deployer.deploy(
            Lottery,
            GOERLI_ETH_USD_PRICE_FEED,
            GOERLI_VRF_COORDINATOR,
            GOERLI_LINK_TOKEN,
            GOERLI_KEYHASH
        )
    }
}
