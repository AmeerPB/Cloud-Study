from flask import Flask, render_template
from routes.ec2_routes import ec2_bp
from routes.ebs_routes import ebs_bp

app = Flask(__name__)

# Register the EC2 blueprint
app.register_blueprint(ec2_bp)
app.register_blueprint(ebs_bp)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
