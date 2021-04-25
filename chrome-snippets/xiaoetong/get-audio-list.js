
function main() {
    const items = $('#comments_list > .list-item')

    results = []

    items.forEach(item => {
        const l = $(item)

        const title = l.find('.content-info .content-title-wrapper span').text()
        const date = l.find('.content-info .content-status span.content-time').text()
        const audioUrl = l.find('div.audioPlayButton').data('mp3')
        const compressedAudioUrl = l.find('div.audioPlayButton').data('mp3compress')

        episode = {
            title,
            date,
            audioUrl,
            compressedAudioUrl
        }
        console.log(episode)
        results.push(episode)
    })

    return results
}

results = main()
console.log(JSON.stringify(results))