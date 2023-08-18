require("dotenv").config();

const API_KEY = process.env.API_KEY
//console.log(API_KEY)
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