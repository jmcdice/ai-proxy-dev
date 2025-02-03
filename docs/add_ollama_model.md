## Adding a New Ollama Model

To add a new model to the Envoy AI Gateway configuration:

1. First, ensure the model is available in your Ollama instance:
   ```bash
   # SSH into Ollama pod
   kubectl exec -it -n ollama deploy/ollama -- bash
   
   # Pull the model
   ollama pull your-model-name
   ```

2. Update the routes configuration (`routes/routes.yaml`) to add the new model:
   ```yaml
   apiVersion: aigateway.envoyproxy.io/v1alpha1
   kind: AIGatewayRoute
   metadata:
     name: envoy-ai-gateway-basic
     namespace: default
   spec:
     # ... existing configuration ...
     rules:
       # ... existing rules ...
       - matches:
           - headers:
               - type: Exact
                 name: x-ai-eg-model
                 value: your-model-name    # Add new model here
         backendRefs:
           - name: envoy-ai-gateway-basic-ollama
   ```

3. Apply the updated configuration:
   ```bash
   kubectl apply -f routes/routes.yaml
   ```

4. Test the new model:
   ```bash
   curl -s --fail \
     -H "Content-Type: application/json" \
     -H "x-ai-eg-model: your-model-name" \
     -d '{
           "model": "your-model-name",
           "messages": [
               {
                   "role": "user",
                   "content": "Hello, are you working?"
               }
           ],
           "stream": false
       }' \
     "http://$GATEWAY_URL/v1/chat/completions"
   ```

Note: No additional backend configuration is needed as all Ollama models use the same backend service. Only the route configuration needs to be updated.
