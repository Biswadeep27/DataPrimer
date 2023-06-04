const API_KEY = "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"

async function fetchData(){
    const response = await fetch("https://api.openai.com/v1/completions", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${API_KEY}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            model: "text-davinci-003",
            prompt: "Hello, how are you doing?",
            max_tokens: 7
        })
    })

    const data = await response.json()
    console.log(data)
}

fetchData()