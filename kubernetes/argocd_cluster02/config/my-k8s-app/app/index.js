const express = require('express');
const app = express();
const port = 3000;

app.get('/', (_, res) => {
  res.send('🚀 App rodando com Argo CD + CI/CD + Ingress NGINX 2025');
});

app.listen(port, () => {
  console.log(`App rodando na porta ${port}`);
});
