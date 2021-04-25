/**
 * get all fanpai long episodes
 * site: https://mp.weixin.qq.com/s/V6LfeY6Mki8VDyFYyfud2Q
 */

items = $('#js_content>p>span')

console.log('total items: ', items.length)

id = 1
results=[]

items.forEach(item => {
    aItems = $(item).find('a')
    if (aItems.length <= 0)
        return

    textNodes = allTextNodes(item)

    aItems.forEach((a, ai) => {
        ep = {}

        ep.id = id++
        ep.no = textNodes[0].textContent.trim()
        ep.title = item.textContent.trim() + (ai > 0 ? " ep2" : "")
        ep.url = a.href

        console.log(`${ep.id}: [${ep.no}] [${ep.title}] ${ep.url.substring(0, 10)}`)

        results.push(ep)        
    })
})

function allTextNodes(el){
  var n, a=[], walk=document.createTreeWalker(el,NodeFilter.SHOW_TEXT,null,false);
  while(n=walk.nextNode()) a.push(n);
  return a;
}