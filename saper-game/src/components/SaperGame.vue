<template>
  <div class="container">
    <input v-model="userInput" class="input-field" v-if="!Started" type="text" placeholder="Адрес эл.кошелька" />
    <button class="button" @click="startGame" v-if="!Started">Начать игру</button>
    <div class="game-board" v-if="gameStarted">
      <div v-for="(row, i) in field" :key="i" class="row">
        <div v-for="(cell, j) in row" :key="j" class="cell" @click="checkField(i, j)" :class="{ open: cell.opened, mine: cell.value === 200 }">
          <span class="grid-item-number" v-if="cell.opened && cell.value !== 200">{{ cell.value }}</span>
          <span class="grid-item-bomb" v-else-if="cell.opened && cell.value === 200">💣</span>
        </div>
      </div>      
    </div>
    <div v-if="isVictory">
      <div class="message">Поздравляем! Вы победили!</div>
      <div class="to-address-field">Адрес:{{ toAddress }} ID токен: 0</div>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3';
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'));
const abi = [
        {
            "constant": false,
            "inputs": [],
            "name": "startGame",
            "outputs": [
              {
                "name": "",
                "type": "uint8"
              }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
          },
          {
            "constant": false,
            "inputs": [
              {
                "name": "endStr",
                "type": "string"
              }
            ],
            "name": "endGame",
            "outputs": [
              {
                "name": "",
                "type": "uint8"
              }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
          },
          {
            "constant": false,
            "inputs": [
              {
                "name": "_i",
                "type": "uint8"
              },
              {
                "name": "_j",
                "type": "uint8"
              }
            ],
            "name": "bombActivate",
            "outputs": [
              {
                "name": "",
                "type": "uint8"
              }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
          },
          {
            "constant": true,
            "inputs": [
              {
                "name": "_i",
                "type": "uint8"
              },
              {
                "name": "_j",
                "type": "uint8"
              }
            ],
            "name": "checkField",
            "outputs": [
              {
                "name": "",
                "type": "uint8[100]"
              }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
          },
          {
            "constant": true,
            "inputs": [],
            "name": "getStatusGame",
            "outputs": [
              {
                "name": "",
                "type": "uint8"
              }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
          },
          {
            "constant": true,
            "inputs": [],
            "name": "getEndStr",
            "outputs": [
              {
                "name": "",
                "type": "string"
              }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
          },
          {
            "constant": false,
            "inputs": [],
            "name": "getRandom",
            "outputs": [
              {
                "name": "",
                "type": "uint8"
              }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
          }
];
const ABI = [{
    "constant": false,
    "inputs": [
      {
        "name": "to",
        "type": "address"
      }
    ],
    "name": "safeMint",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }];
const contractAddress = '0xe7f1725e7734ce288f8367e1bb143e90bb3f0512';
const Certificate = '0x5fbdb2315678afecb367f032d93f642f64180aa3';
const contract = new web3.eth.Contract(abi, contractAddress);
const contract_Certificate = new web3.eth.Contract(ABI, Certificate);
const accounts = await web3.eth.getAccounts();
const userAccount = accounts[0];
export default {
  data() {
    return {
      userInput: '',
      gameStarted: false,
      Started: false,
      toAddress: '',
      isVictory: false,
      closedCells: 100, // Изначально использовано 100 клеток
      field: Array.from({length: 10}, () => Array.from({length: 10}, () => ({ opened: false, value: 0 }))),
    };
  },
  methods: {

    async startGame() {
      if (this.userInput === '') {
        alert('Ошибка! Поле должно быть заполнено.');
      } else {
        try {
          const result = await contract.methods.startGame().send({ from: this.userInput });
          console.log('Транзакция успешно отправлена:', result);
          this.toAddress = Certificate;
          this.gameStarted = true;
          this.Started = true;
        } catch (error) {
          console.error('Ошибка при выполнении запроса startGame:', error);
        } 
      }
    },

    async checkField(i, j) {
      try {
        const fieldState = await contract.methods.checkField(i, j).call();
        const fieldStateString = fieldState.toString();
        const matrix = this.createMatrixFromString(fieldStateString);
        console.log(matrix[i][j]);

        this.openCell(i, j, matrix);
      } catch (error) {
        console.error('Ошибка при выполнении запроса checkField:', error);
      }
    },

    async openCell(i, j, matrix) {
      try {
        if (this.field[i][j].opened) {
          return; // Клетка уже открыта, выходим
        }
        this.field[i][j].opened = true;
        this.closedCells--;
        const value = matrix[i][j];
        if (value === 100) {
          // Открываем соседние пустые клетки
          for (let x = Math.max(i - 1, 0); x <= Math.min(i + 1, 9); x++) {
            for (let y = Math.max(j - 1, 0); y <= Math.min(j + 1, 9); y++) {
              if (x !== i || y !== j) {
                const neighborValue = matrix[x][y];
                if (neighborValue !== 0) {
                  this.openCell(x, y, matrix);
                }
              }
            }
          }
        } else if (value === 200) {
          // Заменяем все клетки на символ "💣"
          for (let x = 0; x < 10; x++) {
            for (let y = 0; y < 10; y++) {
              if (x !== i || y !== j) {
                this.field[x][y].value = "💣";
                this.openCell(x, y, matrix);
              }
            }
          }
        } else {
          this.field[i][j].value = value;
        }
        // Проверяем условие выигрыша
        if (this.closedCells === 12 || this.closedCells == 11 || this.closedCells == 10 || this.closedCells == 9) {
          const winCoordinates = this.getWinCoordinates();
          console.log(winCoordinates);
          const result = await contract.methods.endGame(winCoordinates).call();
          console.log(result.toString());
          if (result.toString() === '200') {
            this.isVictory = true;
            this.gameStarted = false;
            this.toAddress = Certificate;
            await contract.methods.endGame(winCoordinates).send({ from: this.userInput });
            await contract_Certificate.methods.safeMint(userAccount).send({ from: this.userInput });
          }
          
        }
      } catch (error) {
        console.error('Ошибка при выполнении запроса endGame:', error);
      }
    },
    
    getWinCoordinates() {
      const coordinates = [];

      for (let i = 0; i < this.field.length; i++) {
        for (let j = 0; j < this.field[i].length; j++) {
          if (!this.field[i][j].opened) {
            const coordinate = (i < 10 ? "0" + i : i) + (j < 10 ?  j : j);
            coordinates.push(coordinate);
          }
        }
      }

      const formattedCoordinates = coordinates.map(coordinate => coordinate.replace(/^0{1,2}/, '')).join("_");
      return formattedCoordinates;
    },

    createMatrixFromString(str) {
      const numbers = str.split(',');
      if (numbers.length !== 100) {
        console.error('Неверная длина строки');
        return;
      }
      
      const matrix = [];
      let index = 0;
      for (let i = 0; i < 10; i++) {
        const row = [];
        for (let j = 0; j < 10; j++) {
          row.push(Number(numbers[index]));
          index++;
        }
        matrix.push(row);
      }
      
      return matrix;
    },
  },
};
</script>

<style>

.input-field {
  border: 1px solid #ccc;
  padding: 0.5rem;
  font-size: 1rem;
  margin-right: 10px;
}

.to-address-field {
  margin-top: 10px;
  font-size: 16px;
  font-weight: bold;
}

.button-container {
  text-align: center;
  margin-top: 20px;
}

.button {
  display: inline-block;
  background-color: #4caf50;
  color: #ffffff;
  padding: 10px 20px;
  font-size: 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  text-decoration: none;
  transition: background-color 0.3s ease;
}

.button:hover {
  background-color: #9ef8a3;
}

.container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

.game-board {
  display: flex;
  flex-wrap: wrap;
  width: 20cm;
}

.row {
  display: flex;
  flex-basis: 20%;
}

.grid-item-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2cm;
  height: 2cm;
  margin: 0.1cm;
  font-size: 30px;
  font-weight: bold;
  background-color: #ffffffa9;
}

.grid-item-bomb {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2cm;
  height: 2cm;
  margin: 0.1cm;
  font-size: 30px;
  font-weight: bold;
  background-color: red;
}

.message{
  background-color: #32a852;
  color: #000000;
  padding: 10px;
  font-size: 18px;
  text-align: center;
  margin-top: 20px;
  border-radius: 8px;
}

.cell {
  width: 2cm;
  height: 2cm;
  margin: 0.1cm;
  background-color: gray;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
}

.open {
  background-color: white;
}
</style>