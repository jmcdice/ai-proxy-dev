curl -s -X POST https://ollama.pool-side.cc/api/chat -d '{
  "model": "phi4",
  "messages": [
    {
      "role": "user",
      "content": "What is cloud computing and why is it important? Please keep it brief."
    }
  ],
  "stream": false
}' | jq -r '.message.content' 
