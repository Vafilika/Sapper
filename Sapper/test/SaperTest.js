const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const {ethers} = require("hardhat")

describe.only("Проверка логики сапера", function () {

    async function deploySaper() {
        const [owner, otherAccount] = await ethers.getSigners();

        const SaperCertificate = await ethers.getContractFactory("SaperCertificate");
        const saperCertificate = await SaperCertificate.deploy();

        const Saper = await ethers.getContractFactory("Saper");
        const saper = await Saper.deploy(await saperCertificate.getAddress());
        await saperCertificate.connect(owner).setSaper(await saper.getAddress());

        return { saperCertificate, saper, owner, otherAccount };
    }

    describe("Проверка создания начального поля для игры для конкретного пользователя", function () {
        it("Попытка генерации игрового поля - статус игры до генерации = 0", async function () {
            const { saperCertificate, saper, owner, otherAccount } = await loadFixture(deploySaper);
            expect(await saper.connect(otherAccount).getStatusGame()).to.equal(ethers.parseUnits("0", 0));
        });
        it("Попытка генерации игрового поля - статус игры после генерации = 1", async function () {
            const { saperCertificate, saper, owner, otherAccount } = await loadFixture(deploySaper);
            await saper.connect(otherAccount).startGame();
            expect(await saper.connect(otherAccount).getStatusGame()).to.equal(ethers.parseUnits("1", 0));
        });
        it("Попытка пользователь наткнулся на мину и сообщил об этом системе - статус игры изменился на 0", async function () {
            const { saperCertificate, saper, owner, otherAccount } = await loadFixture(deploySaper);
            await saper.connect(otherAccount).startGame();
            for (let i = 0; i < 100; i++) {
                let checkArr = await saper.connect(otherAccount).checkField(ethers.parseUnits(""+Math.floor(i/10), 0), ethers.parseUnits(""+(i%10), 0));
                if (checkArr[i] == 200) {
                    await saper.connect(otherAccount).bombActivate(ethers.parseUnits(""+Math.floor(i/10), 0), ethers.parseUnits(""+(i%10), 0));
                    break;
                }
            }
            expect(await saper.connect(otherAccount).getStatusGame()).to.equal(ethers.parseUnits("0", 0));
        });
        // Данный тест воспроизводится долго, так как необходимо обходить все клетки игрового поля
        it(`Попытка найти все бомбы и завершить игру - 
        до завершения игры у пользователя нет нашей NFT;
        статус игры должен измениться на 2;
        NFT начислили на аккаунт;
        Начать новую игру запрещено;`, async function () {
            const { saperCertificate, saper, owner, otherAccount } = await loadFixture(deploySaper);
            await saper.connect(otherAccount).startGame();
            function consoleLogGame(tmpArr) { // Удобный вывод поля 10 х 10
                let tmpStr = "-----------------------------------\n";
                for (let i = 0; i < 10; i++) {
                    
                    for (let j = 0; j < 10; j++) {
                        let add = tmpArr[i*10 + j];
                        if (add == 200) {
                            add = "*";
                        }
                        if (j == 0) {
                            tmpStr = tmpStr + "| " + add;
                        } else {
                            tmpStr = tmpStr + ", " + add;
                        }
                    }
                    tmpStr = tmpStr + " |\n";
                }
                tmpStr = tmpStr + "-----------------------------------";
                return tmpStr;
            }
            let ans = "";
            let check = true;
            for (let i = 0; i < 100; i++) {
                console.log(i);
                let checkArr = await saper.connect(otherAccount).checkField(ethers.parseUnits(""+Math.floor(i/10), 0), ethers.parseUnits(""+(i%10), 0));
                console.log(consoleLogGame(checkArr));
                if (checkArr[i] == 200) {
                    if (check) {
                        ans = ans + i;
                        check = false;
                    } else {
                        ans = ans + "_" + i;
                    }
                }
            }
            console.log(ans);
            expect(await saperCertificate.connect(otherAccount).balanceOf(otherAccount.address)).to.equal(ethers.parseUnits("0", 0));
            await saper.connect(otherAccount).endGame(ans);
            expect(await saper.connect(otherAccount).getStatusGame()).to.equal(ethers.parseUnits("2", 0));
            expect(await saperCertificate.connect(otherAccount).balanceOf(otherAccount.address)).to.equal(ethers.parseUnits("1", 0));
            await expect(saper.connect(otherAccount).startGame())
                .to.be.revertedWith('After completing the game, it is impossible to complete the game again!');
        });
    });

});
  