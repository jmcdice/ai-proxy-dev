curl -X POST https://ollama.pool-side.cc/api/embeddings -d '{
  "model": "phi4",
  "prompt": "Cloud computing is important"
}' | jq

