const links = document.querySelectorAll('[rel="icon"]')


const link = []
links.forEach((node)=>{
    link.push(node.href)
})

alert(JSON.stringify(link))
if(link.length > 0){
    return link[0]
}