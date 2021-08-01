function ldsfunds() {
    let fundItems = $x('//*[@id="my-money"]/div[2]/div[3]/div[4]/a')
    let funds = []

    fundItems.forEach(item => {
        let name = $('div > div:nth-child(1) > div:nth-child(1) .p-name', item).text()
        let totalAmount = parseNumber($('div  > div:nth-child(1) > div:nth-child(2) span', item).text())
        let dailyProfit = parseNumber($('div  > div:nth-child(3) > div:nth-child(1) > span', item).text())
        let totalProfit = parseNumber($('div  > div:nth-child(2) > div:nth-child(1)', item).text())
    
        funds.push({
            name,
            totalAmount,
            dailyProfit,
            totalProfit,
        })
    })

    return funds
}

function parseNumber(s) {
    s = s.trim()
    s = s.replace(',', '')
    return Number.parseFloat(s)
}

console.log(JSON.stringify(ldsfunds()))
