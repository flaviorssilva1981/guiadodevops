const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Servir arquivos estáticos (CSS, imagens, etc.)
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (_, res) => {
  const html = `
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🚀 GitHub Actions + Argo CD + CI/CD Pipeline App </title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                padding: 20px;
                background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
                color: white;
                text-align: center;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }
            .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 20px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
                max-width: 800px;
            }
            h1 {
                font-size: 2.5em;
                margin-bottom: 30px;
                text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
                background: linear-gradient(45deg, #00d4ff, #ff6b6b);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .devops-image {
                width: 300px;
                height: 300px;
                margin: 30px auto;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                position: relative;
                overflow: hidden;
            }
            .devops-image::before {
                content: "∞";
                font-size: 120px;
                font-weight: bold;
                color: white;
                text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
                position: relative;
                z-index: 2;
            }
            .devops-image::after {
                content: "";
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: 
                    radial-gradient(circle at 30% 30%, rgba(0, 212, 255, 0.3) 0%, transparent 50%),
                    radial-gradient(circle at 70% 70%, rgba(255, 107, 107, 0.3) 0%, transparent 50%);
                z-index: 1;
            }
            .dev-text {
                position: absolute;
                top: 35%;
                left: 20%;
                font-size: 18px;
                font-weight: bold;
                color: white;
                z-index: 3;
                text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.7);
            }
            .ops-text {
                position: absolute;
                top: 35%;
                right: 20%;
                font-size: 18px;
                font-weight: bold;
                color: white;
                z-index: 3;
                text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.7);
            }
            .description {
                font-size: 1.3em;
                line-height: 1.6;
                margin: 30px 0;
                opacity: 0.95;
                max-width: 600px;
                margin-left: auto;
                margin-right: auto;
            }
            .tech-stack {
                margin-top: 40px;
                padding: 25px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 15px;
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            .tech-item {
                display: inline-block;
                margin: 8px 12px;
                padding: 10px 20px;
                background: linear-gradient(45deg, rgba(0, 212, 255, 0.2), rgba(255, 107, 107, 0.2));
                border-radius: 25px;
                font-size: 1em;
                font-weight: 500;
                border: 1px solid rgba(255, 255, 255, 0.3);
                transition: all 0.3s ease;
            }
            .tech-item:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
                background: linear-gradient(45deg, rgba(0, 212, 255, 0.3), rgba(255, 107, 107, 0.3));
            }
            .status-indicator {
                position: fixed;
                top: 20px;
                right: 20px;
                background: rgba(76, 175, 80, 0.9);
                color: white;
                padding: 10px 20px;
                border-radius: 25px;
                font-size: 0.9em;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
                animation: pulse 2s infinite;
            }
            @keyframes pulse {
                0% { transform: scale(1); }
                50% { transform: scale(1.05); }
                100% { transform: scale(1); }
            }
        </style>
    </head>
    <body>
        <div class="status-indicator">
            🟢 System Online
        </div>
        
        <div class="container">
            <h1>🚀 App Running with GitHub Actions + Argo CD + CI/CD + Ingress NGINX  SPFC  </h1>
            
            <div class="devops-image">
                <div class="dev-text">DEV</div>
                <div class="ops-text">OPS</div>
            </div>
            
            <div class="description">
                <p>Your DevOps application is working perfectly! This image represents the continuous cycle of development and operations that your infrastructure implements.</p>
                <p>The infinite loop symbolizes the continuous integration and continuous delivery (CI/CD) pipeline where GitHub Actions handles CI and Argo CD manages CD automatically.</p>
            </div>
            
            <div class="tech-stack">
                <span class="tech-item">⚡ Argo CD</span>
                <span class="tech-item">🔄 CI/CD</span>
                <span class="tech-item">🌐 Ingress NGINX</span>
                <span class="tech-item">🐳 Kubernetes</span>
                <span class="tech-item">🚀 Express.js</span>
                <span class="tech-item">🎯 DevOps</span>
                <span class="tech-item">⚙️ GitHub Actions</span>
            </div>
        </div>
    </body>
    </html>
  `;
  
  res.send(html);
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
