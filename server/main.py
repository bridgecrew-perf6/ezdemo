from enum import Enum
from http import HTTPStatus
import flask
from flask import jsonify, request, send_from_directory, abort
from werkzeug.utils import safe_join
from flask_cors import CORS, cross_origin
from waitress import serve
import subprocess
import os, json

from werkzeug.wrappers import response

base_path = os.path.dirname(__file__)

app = flask.Flask(__name__)
CORS(app)

class ProviderName(str, Enum):
  aws = "AWS"
  # azure = "Azure"
  # vmware = "VMWare"
  # kvm = "KVM"

@app.route('/')
@cross_origin()
def hello():
  return 'Hello world'

@app.route('/<target>/config')
def get_config(target):
  response = None
  conf_file = base_path + '/' + target + '/config.json'
  if os.path.isfile(conf_file) and os.path.getsize(conf_file) > 0:
    with open(conf_file) as f:
      response = json.load(f)
  else:
    with open(conf_file + '-template') as f:
      response = json.load(f)
  return response

@app.route('/<target>/deploy', methods = ['POST'])
async def init(target: str):
  conf_file = base_path + '/' + target + '/config.json'
  with open(conf_file, 'w') as f:
    json.dump(request.get_json(force=True, silent=True), f)
  def inner():
    process = subprocess.Popen(['./01-init.sh', target], cwd=base_path, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline,''):
      yield line
  return flask.Response(inner(), mimetype='html/text')

@app.route('/<target>/destroy', methods = ['POST'])
async def destroy(target: str):
  def inner():
    process = subprocess.Popen(['./99-destroy.sh', target], cwd=base_path, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline,''):
      yield line
  return flask.Response(inner(), mimetype='html/text')

@app.route('/<target>/log')
async def log(target: str):
  def inner():
    process = subprocess.Popen(['tail', '-f', target + '/run.log'], cwd=base_path, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline,''):
      yield line
  return flask.Response(inner(), mimetype='html/text')

@app.route('/providers')
def read_providers():
    return jsonify(list(x for x in ProviderName))

allowed_files = ['aws/run.log', 'aws/terraform.tfstate', 'generated/controller.prv_key']

@app.route('/isfile/<path:logfile>')
def isFile(logfile: str):
  if logfile not in allowed_files or not os.path.exists(logfile):
    return abort(404)
  else:
    return flask.Response(status=HTTPStatus.OK)

@app.route('/file/<path:logfile>')
def get_log(logfile: str):
  if logfile not in allowed_files:
    return abort(400)
  try:
    return 
  except FileNotFoundError:
    return abort(400)

if __name__ == '__main__':
  if "DEV" in os.environ:
   app.run(
     debug = True,
     port=3001
    )
  else:
    serve(app, host="0.0.0.0", port=3001)