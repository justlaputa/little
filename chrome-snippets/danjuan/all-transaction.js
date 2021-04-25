function listTransactions() {
    const result = []
    const list = $$('a.list-row')

    list.forEach(l => {
        const txElem = $(l)
        const type = txElem.find('.top > p.left > i').text()
        const name = txElem.find('.top > p.left > span.name').text()
        let from = ''
        let to = ''
        let target = ''

        if (name.indexOf('->') >= 0) {
            [from, to] = name.split('->')
        } else {
            target = name
        }

        const amountText = txElem.find('.top > p.right').text()
        const amount = amountText.substring(0, amountText.length - 1)
        const amountUnit = amountText.substr(-1)

        const date = txElem.find('.bottom > small:first-child()').text()

        result.push({
            date,
            type,
            target,
            from,
            to,
            amount,
            amountUnit,
        })
    })

    return result
}

transactions = listTransactions()
console.log(JSON.stringify(transactions))