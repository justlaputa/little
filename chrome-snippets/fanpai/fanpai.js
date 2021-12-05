function main() {
    let results = []

    $('.list-item').forEach(item => {
        let title = $('span.content-title', item)[0].textContent
        let audioUrl = ''
        let playButton = $('div.audioPlayButton', item)
        if (playButton.length > 0) {
            if (playButton[0].attributes["data-mp3compress"]) {
                audioUrl = playButton[0].attributes["data-mp3compress"].value

                results.push({
                    title,
                    audio_url: audioUrl,
                    publish_date_short: "2020-10-20",
                })
            }
        }
    })

    return results
}

let r = main()
console.log(JSON.stringify(r))