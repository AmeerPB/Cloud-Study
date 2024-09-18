from flask import Flask, render_template, request, Response
import os
import subprocess
import logging
import time

app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Root directory where the script folders are located
SCRIPTS_DIR = '/root/cloudsec-website/scripts/'

@app.route('/')
def index():
    # List all bash scripts in all directories
    scripts = []
    for dirpath, _, filenames in os.walk(SCRIPTS_DIR):
        for filename in filenames:
            if filename.endswith('.sh'):
                scripts.append(os.path.relpath(os.path.join(dirpath, filename), SCRIPTS_DIR))
    return render_template('index.html', scripts=scripts)

@app.route('/run/<script_name>', methods=['GET'])
def run_script(script_name):
    script_path = os.path.join(SCRIPTS_DIR, script_name)
    
    # Make sure the script exists and is a .sh file
    if os.path.exists(script_path) and script_name.endswith('.sh'):
        try:
            logging.info(f"Running script: {script_name}")

            # Run the bash script
            result = subprocess.run(['/bin/bash', script_path], capture_output=True, text=True)
            output = result.stdout
            error = result.stderr

            if error:
                logging.error(f"Script error: {error}")
                output += f"\nError:\n{error}"
        
        except Exception as e:
            logging.error(f"Exception occurred while running the script: {str(e)}")
            output = f"An error occurred: {str(e)}"
    
    else:
        output = "Error: Script not found or invalid script!"
    
    return render_template('output.html', script_name=script_name, output=output)

@app.route('/stream_all_combine')
def stream_all_combine():
    def generate():
        try:
            # Find all combine.sh scripts across the directories
            combine_scripts = []
            for dirpath, _, filenames in os.walk(SCRIPTS_DIR):
                for filename in filenames:
                    if filename == 'combine.sh':
                        combine_scripts.append(os.path.join(dirpath, filename))

            # Run each combine.sh script
            for script in combine_scripts:
                yield f"data: Starting {script}\n\n"
                logging.info(f"Running script: {script}")
                process = subprocess.Popen(['/bin/bash', script], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                for stdout_line in iter(process.stdout.readline, ''):
                    yield f"data: {stdout_line}\n\n"
                process.stdout.close()
                process.wait()
                stderr_output = process.stderr.read()
                if stderr_output:
                    yield f"data: Error in {script}:\n{stderr_output}\n\n"
                time.sleep(1)  # Small delay to avoid overwhelming the client
        except Exception as e:
            logging.error(f"Exception occurred while running the scripts: {str(e)}")
            yield f"data: An error occurred: {str(e)}\n\n"

    return Response(generate(), content_type='text/event-stream')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

