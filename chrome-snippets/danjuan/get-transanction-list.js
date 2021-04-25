
function addAll() {
    const txItems = $$('div.sc-1jm5xe9-2 a.ktXxUc')
    txItems.forEach(item => {
        let title = item.querySelector('div.sc-18l5bqn-4').textContent
        let description = item.querySelector('div > div:nth-child(1)').textContent
        let amount = item.querySelector('span.number__28359').childNodes[0].nodeValue 

        let t = {title, description, amount}
        txs.push(t)
        console.log(t)
    })
}

addAll()
console.log(txs.length)