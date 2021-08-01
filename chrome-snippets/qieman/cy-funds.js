function cyfunds() {
    let fundItems = $x('//*[@id="app"]/div[3]/div[2]/div/div/div/div/div[4]/div[position() >= 3]/div')
    let funds = []

    fundItems.forEach(item => {
        let name = $('p', item).childNodes[0].textContent
        let totalAmount = $('div.profits > div:nth-child(1) > span:nth-child(1)', item).childNodes[0].textContent
        let dailyProfit = $('div.profits > div:nth-child(2) > span:nth-child(1)', item).childNodes[0].textContent
        let totalProfit = $('div.profits > div:nth-child(3) > span:nth-child(1)', item).childNodes[0].textContent
    
        funds.push({
            name,
            totalAmount,
            dailyProfit,
            totalProfit,
        })
    })

    return funds
}

console.log(JSON.stringify(cyfunds(), null, ' '))
