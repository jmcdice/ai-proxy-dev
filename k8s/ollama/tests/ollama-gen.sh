
curl -X POST https://ollama.pool-side.cc/api/generate -d '{
  "model": "phi4",
  "prompt": "What is a cloud computing and why is it important? Please keep it brief.",
  "stream": false
}' | jq

