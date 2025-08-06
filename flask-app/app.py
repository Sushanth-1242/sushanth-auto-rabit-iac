from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    return render_template_string('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello from DevOps</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
            animation: fadeInUp 1s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        
        .feature-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }
        
        .feature-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .footer {
            margin-top: 2rem;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        .tech-stack {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin: 1rem 0;
            flex-wrap: wrap;
        }
        
        .tech-badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Hello from DevOps!</h1>
        <p class="subtitle">Welcome to your containerized Flask application</p>
        
        <div class="tech-stack">
            <span class="tech-badge">🐍 Python Flask</span>
            <span class="tech-badge">🐳 Docker</span>
            <span class="tech-badge">⚙️ DevOps Ready</span>
        </div>
        
        <div class="features">
            <div class="feature-card">
                <div class="feature-icon">🌐</div>
                <h3>Modern UI</h3>
                <p>Beautiful, responsive design with smooth animations</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📦</div>
                <h3>Containerized</h3>
                <p>Runs seamlessly in Docker containers</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">⚡</div>
                <h3>Fast Deploy</h3>
                <p>Quick setup and deployment ready</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔧</div>
                <h3>DevOps Friendly</h3>
                <p>Built with CI/CD and automation in mind</p>
            </div>
        </div>
        
        <div class="footer">
            <p>Flask App running on port 5000 | Built with ❤️ for DevOps</p>
            <p>Container Status: ✅ Running | Environment: Production Ready</p>
        </div>
    </div>
</body>
</html>
    ''')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
