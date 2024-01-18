// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";

interface ISaperCertificate {
    function safeMint(address to) external;
}

contract Saper {    
    mapping(address => uint8[10][10]) private _userField;
    mapping(address => uint8) private _statusGame;
    ISaperCertificate public saperCertificate;
    uint8 public mine = 12;
    uint256 private _nextRandId;

    constructor(address _saperCertificate) {
        saperCertificate = ISaperCertificate(_saperCertificate);
    }

    function startGame() external returns (uint8) {
        require(_statusGame[msg.sender] != 2, "After completing the game, it is impossible to complete the game again!");
        _statusGame[msg.sender] = 1;
        uint8[10][10] memory arr;
        for (uint8 m = 0; m < mine; m++) {
            uint8 rnd = getRandom();
            uint8 i = rnd / 10;
            uint8 j = rnd % 10;
            if (arr[i][j] == 200) {
                continue;
            }
            arr[i][j] = 200;
            //LU
            if (i == 0 && j == 0) {
                if (arr[i+1][j] != 200) {
                    arr[i+1][j]++;
                }
                if (arr[i][j+1] != 200) {
                    arr[i][j+1]++;
                }
                if (arr[i+1][j+1] != 200) {
                    arr[i+1][j+1]++;
                }
                continue;
            }
            //LD
            if (i == 9 && j == 0) {
                if (arr[i-1][j] != 200) {
                    arr[i-1][j]++;
                }
                if (arr[i][j+1] != 200) {
                    arr[i][j+1]++;
                }
                if (arr[i-1][j+1] != 200) {
                    arr[i-1][j+1]++;
                }
                continue;
            }
            //RU
            if (i == 0 && j == 9) {
                if (arr[i+1][j] != 200) {
                    arr[i+1][j]++;
                }
                if (arr[i][j-1] != 200) {
                    arr[i][j-1]++;
                }
                if (arr[i+1][j-1] != 200) {
                    arr[i+1][j-1]++;
                }
                continue;
            } 
            //RD
            if (i == 9 && j == 9) {
                if (arr[i-1][j] != 200) {
                    arr[i-1][j]++;
                }
                if (arr[i][j-1] != 200) {
                    arr[i][j-1]++;
                }
                if (arr[i-1][j-1] != 200) {
                    arr[i-1][j-1]++;
                }
                continue;
            }
            //L
            if (j == 0) {
                if (arr[i][j+1] != 200) {
                    arr[i][j+1]++;
                }
                if (arr[i-1][j] != 200) {
                    arr[i-1][j]++;
                }
                if (arr[i+1][j] != 200) {
                    arr[i+1][j]++;
                }
                if (arr[i-1][j+1] != 200) {
                    arr[i-1][j+1]++;
                }
                if (arr[i+1][j+1] != 200) {
                    arr[i+1][j+1]++;
                }
                continue;
            }
            //D
            if (i == 9) {
                if (arr[i-1][j] != 200) {
                    arr[i-1][j]++;
                }
                if (arr[i][j-1] != 200) {
                    arr[i][j-1]++;
                }
                if (arr[i][j+1] != 200) {
                    arr[i][j+1]++;
                }
                if (arr[i-1][j-1] != 200) {
                    arr[i-1][j-1]++;
                }
                if (arr[i-1][j+1] != 200) {
                    arr[i-1][j+1]++;
                }
                continue;
            } 
            //R
            if (j == 9) {
                if (arr[i][j-1] != 200) {
                    arr[i][j-1]++;
                }
                if (arr[i-1][j] != 200) {
                    arr[i-1][j]++;
                }
                if (arr[i+1][j] != 200) {
                    arr[i+1][j]++;
                }
                if (arr[i-1][j-1] != 200) {
                    arr[i-1][j-1]++;
                }
                if (arr[i+1][j-1] != 200) {
                    arr[i+1][j-1]++;
                }
                continue;
            }
            //U
            if (i == 0) {
                if (arr[i+1][j] != 200) {
                    arr[i+1][j]++;
                }
                if (arr[i][j-1] != 200) {
                    arr[i][j-1]++;
                }
                if (arr[i][j+1] != 200) {
                    arr[i][j+1]++;
                }
                if (arr[i+1][j-1] != 200) {
                    arr[i+1][j-1]++;
                }
                if (arr[i+1][j+1] != 200) {
                    arr[i+1][j+1]++;
                }
                continue;
            }

            if (arr[i+1][j] != 200) {
                arr[i+1][j]++;
            }
            if (arr[i+1][j+1] != 200) {
                arr[i+1][j+1]++;
            }
            if (arr[i+1][j-1] != 200) {
                arr[i+1][j-1]++;
            }
            if (arr[i-1][j] != 200) {
                arr[i-1][j]++;
            }
            if (arr[i-1][j+1] != 200) {
                arr[i-1][j+1]++;
            }
            if (arr[i-1][j-1] != 200) {
                arr[i-1][j-1]++;
            }
            if (arr[i][j-1] != 200) {
                arr[i][j-1]++;
            }
            if (arr[i][j+1] != 200) {
                arr[i][j+1]++;
            }
        }
        _userField[msg.sender] = arr;
        return 200;
    }

    // Submit bomb indexes in ascending order with underscores. The numbering of the indexes starts from 0. See the example: "0_2_15_46_77_99"
    function endGame(string memory endStr) external returns (uint8) {
        require(_statusGame[msg.sender] == 1, "To finish the game, you need to start it, and if you have already received a certificate, then you cannot get the 2nd certificate!");
        if (keccak256(abi.encodePacked(endStr)) != keccak256(abi.encodePacked(getEndStr()))) {
            _statusGame[msg.sender] = 0;
            return 204;
        }
        saperCertificate.safeMint(msg.sender);
        _statusGame[msg.sender] = 2;
        return 200;
    }

    function bombActivate(uint8 _i, uint8 _j) external returns (uint8) {
        require(
            _i >= 0 && _i <= 9 && _j >= 0 && _j <= 9,
            "Going beyond the boundaries of the playing field!"
        );
        require(
            _statusGame[msg.sender] == 1,
            "To explode on a bomb, you must have the status of game 1, if you have completed the game, then you will not be able to activate the bomb either!"
        );
        require(
            _userField[msg.sender][_i][_j] == 200,
            "You cannot complete the game because this cell is not a bomb ;)"
        );

        _statusGame[msg.sender] = 0;

        return 200;
    }

    // 100 - an empty cell; all arr. = 200 - The end of the game you hit a bomb; 0 - these cells do not open with the current click on the field
    // The function shows what the state of the playing field will be after the first click on the field
    function checkField(uint8 _i, uint8 _j) external view returns (uint8[100] memory) {
        require(
            _i >= 0 && _i <= 9 && _j >= 0 && _j <= 9,
            "Going beyond the boundaries of the playing field!"
        );
        uint8[100] memory answer;
        if (_userField[msg.sender][_i][_j] == 200) {
            for (uint8 q = 0; q < 100; q++) {
                answer[q] = 200;
            }
            return answer;
        }
        uint8[80] memory tmp;
        uint8 idTmp = 1;
        uint8[10][10] memory userField = _userField[msg.sender];
        uint8[12][12] memory arrTmp;
        for (uint8 t = 0; t < 12; t++) {
            arrTmp[t][0] = 201;
            arrTmp[t][11] = 201;
            arrTmp[0][t] = 201;
            arrTmp[11][t] = 201;
        }
        tmp[0] = (_i+1)*12 + _j+1;
        uint8 i = 0;
        uint8 j = 0;
        while (idTmp > 0) {
            uint8[80] memory newTmp;
            uint8 idNewTmp = 0;
            for (uint8 q = 0; q < idTmp; q++) {
                i = tmp[q] / 12;
                j = tmp[q] % 12;
                if (arrTmp[i][j] == 201) {
                    continue;
                }
                arrTmp[i][j] = 201;
                if (userField[i-1][j-1] == 0) {
                    newTmp[idNewTmp] = (i-1)*12 + j;
                    newTmp[idNewTmp+1] = (i+1)*12 + j;
                    newTmp[idNewTmp+2] = i*12 + j-1;
                    newTmp[idNewTmp+3] = i*12 + j+1;
                    idNewTmp = idNewTmp + 4;
                    answer[(i-1)*10 + j-1] = 100;
                } else {
                    answer[(i-1)*10 + j-1] = userField[i-1][j-1];
                }
            }
            tmp = newTmp;
            idTmp = idNewTmp;
        }
        return answer;
    }

    // 0 - not game; 1 - start game; 2 - end game and send NFT
    function getStatusGame() external view returns(uint8) {
        return _statusGame[msg.sender];
    }

    function getEndStr() internal view returns (string memory) {
        bytes memory answer;
        uint8[10][10] memory userField = _userField[msg.sender];
        bool check = true;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 10; j++) {
                if (userField[i][j] == 200) {
                    if (check) {
                        answer = abi.encodePacked(Strings.toString(i*10 + j));
                        check = false;
                    } else {
                        answer = abi.encodePacked(answer, "_");
                        answer = abi.encodePacked(answer, Strings.toString(i*10 + j));
                    }
                }
            }
        }
        return string(answer);
    }

    function getRandom() internal returns (uint8) {
        uint8 randomnumber = uint8(uint256(keccak256(abi.encodePacked(msg.sender, _nextRandId))) % 100);
        _nextRandId++;
        return randomnumber;
    }

}
