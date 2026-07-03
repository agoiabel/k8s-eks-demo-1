const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// All configuration comes from environment variables with fallbacks.
// This pattern means the same image runs identically everywhere —
// local Docker, minikube, EKS — with different behaviour controlled
// purely by what the environment provides, never by changing the code.
const VERSION = process.env.APP_VERSION || 'unknown';
const WELCOME = process.env.WELCOME_MESSAGE || 'Hello from Node.js!';

// Root endpoint — returns useful info for confirming deployments.
// os.hostname() inside a container returns the pod name, so each
// response tells you exactly which replica answered the request.
app.get('/', (req, res) => {
  res.json({
    message: WELCOME,
    version: VERSION,
    pod: os.hostname(),
    timestamp: new Date().toISOString(),
  });
});

// Kubernetes uses this endpoint for liveness and readiness probes.
// If this stops returning 200, kubelet restarts the container.
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}, version ${VERSION}`);
  });
}

// Export for testing — Jest can import the app without
// starting a real server by calling close() after tests.
module.exports = { app };