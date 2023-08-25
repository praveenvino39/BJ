
const unsafeMethods = ["eth_requestAccounts", "eth_accounts", "personal_sign", "eth_sign"]
window.ethereum = {
    enable: async () => {
        if (event.method === "eth_requestAccounts") {
            signer.postMessage(JSON.stringify(event))
        }
        return new Promise((resolve, reject) => {
            const handler = (resultEvent) => {
                if (resultEvent.data.method === event.method) {
                    if (resultEvent.data.status === true) {
                        resolve(resultEvent.data.data)
                        window.removeEventListener('message', handler)
                    } else {
                        reject(resultEvent.data.error)
                        window.removeEventListener('message', handler)
                    }
                }
            }
            window.addEventListener('message', handler)
        })
    },
    request: async (event) => {
        alert(event.method)
        if (unsafeMethods.includes(event.method)) {
            signer.postMessage(JSON.stringify(event))
            return new Promise((resolve, reject) => {
                const handler = (resultEvent) => {
                    if (resultEvent.data.method === event.method) {
                        if (resultEvent.data.status === true) {
                            resolve(resultEvent.data.data)
                            window.removeEventListener('message', handler, false)
                        } else {
                            reject(resultEvent.data.error)
                            window.removeEventListener('message', handler, false)
                        }
                    }
                }
                window.addEventListener('message', handler)
            })
        } else {
            const response = await fetch("https://goerli.infura.io/v3/2ff47e51ff1f4804865ba892c7efc70c", {
                method: 'POST',
                body: JSON.stringify(
                    {
                        "id": 1,
                        "jsonrpc": "2.0",
                        "method": event.method,
                        "params": event.params
                    }
                )
            })
            const data = await response.json()
            return new Promise((resolve, reject) => {
                if (!data.error) {
                    resolve(data.result)
                } else {
                    reject(data.error)
                }
            })

        }
    }
}