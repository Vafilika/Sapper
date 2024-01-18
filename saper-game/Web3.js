import Web3 from 'web3';

export default {
  data() {
    return {
      web3: null,
    };
  },
  created() {
    this.initWeb3();
  },
  methods: {
    initWeb3() {
      if (typeof web3 !== 'undefined') {
        this.web3 = new Web3(web3.currentProvider);
      } else {
        console.log('No web3 provider found. Please install MetaMask or use a compatible browser.');
      }
    },
  },
};