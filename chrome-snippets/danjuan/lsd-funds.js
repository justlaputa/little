function ldsfunds() {
    let fundItems = $x('//*[@id="app"]/div[1]/div[2]/div[5]/div[2]/div')
    let funds = []

    fundItems.forEach(item => {
        let name = $('div > a > span:nth-child(1)', item).text()
        let totalAmount = parseNumber($('div  > p:nth-child(1) > span:nth-child(1)', item).text())
        let dailyProfit = parseNumber($('div  > p:nth-child(2) > span:nth-child(1)', item).text())
        let totalProfit = parseNumber($('div  > p:nth-child(3) > span:nth-child(1)', item).text())
    
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
