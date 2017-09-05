#!/usr/bin/env python3

from io import StringIO
import logging
import os
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.httpserver
import importlib.util
import tarfile
import subprocess
import cloudpickle as pickle
from tornado.options import define, options
from prometheus_client import CollectorRegistry, generate_latest, start_http_server, Summary, Counter, Histogram, Gauge
import json


# Test
#curl -i -X POST -v -H "Transfer-Encoding: chunked" \
#   -F "file=@bundle.tar.gz" \
#   http://[host]:[port]/api/v1/model/drop/<model_type>/<model_name>/<model_version?>

define('PIPELINE_DROP_PATH', default='', help='path to drop', type=str)
define('PIPELINE_DROP_SERVER_PORT', default='', help='tornado http drop server listen port', type=int)

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.ERROR)

CH = logging.StreamHandler()
CH.setLevel(logging.ERROR)
LOGGER.addHandler(CH)

TORNADO_ACCESS_LOGGER = logging.getLogger('tornado.access')
TORNADO_ACCESS_LOGGER.setLevel(logging.ERROR)

TORNADO_APPLICATION_LOGGER = logging.getLogger('tornado.application')
TORNADO_APPLICATION_LOGGER.setLevel(logging.ERROR)

TORNADO_GENERAL_LOGGER = logging.getLogger('tornado.general')
TORNADO_GENERAL_LOGGER.setLevel(logging.ERROR)

class Application(tornado.web.Application):
    def __init__(self):
        handlers = [
            (r'/healthz', HealthzHandler),

            # url: /api/v1/model/drop/$PIPELINE_MODEL_TYPE/$PIPELINE_MODEL_NAME
            (r'/api/v1/model/drop/([a-zA-Z\-0-9\.:,_]+)/([a-zA-Z\-0-9\.:,_]+)',
             ModelDropPython3Handler),
        ]
        settings = dict(
            drop_path=options.PIPELINE_DROP_PATH,
            model_server_port=options.PIPELINE_DROP_SERVER_PORT,
            request_timeout=120,
            debug=True,
            autoescape=None,
        )
        tornado.web.Application.__init__(self, handlers, **settings)

    def fallback(self):
        LOGGER.warn('Model Server Application fallback: {0}'.format(self))
        return 'fallback!'


class HealthzHandler(tornado.web.RequestHandler):

    @tornado.web.asynchronous
    def get(self):
        try:
            self.set_status(200, None)
            self.add_header('Content-Type', 'text/plain')
            self.finish()
        except Exception as e:
            logging.exception('HealthzHandler.get: Exception {0}'.format(str(e)))


class ModelDropPython3Handler(tornado.web.RequestHandler):

    def post(self, model_type, model_name):
        model_key_list = [model_type, model_name]
        model_key = '/'.join(model_key_list)

        fileinfo = self.request.files['file'][0]
        model_file_source_bundle_path = fileinfo['filename']
        (_, filename) = os.path.split(model_file_source_bundle_path)

        model_base_path = self.settings['drop_path']
        model_base_path = os.path.expandvars(model_base_path)
        model_base_path = os.path.expanduser(model_base_path)
        model_base_path = os.path.abspath(model_base_path)

        bundle_path = os.path.join(model_base_path, *model_key_list) 
        bundle_path_filename = os.path.join(bundle_path, filename)

        os.makedirs(bundle_path, exist_ok=True)
        with open(bundle_path_filename, 'wb+') as fh:
            try:
                fh.write(fileinfo['body'])
                LOGGER.info('{0} uploaded {1}, saved as {2}'.format(str(self.request.remote_ip), str(filename),
                                                                bundle_path_filename))
                LOGGER.info('Extracting bundle {0} into {1}: begin'.format(filename, bundle_path))
                with tarfile.open(bundle_path_filename, 'r:gz') as tar:
                    tar.extractall(path=bundle_path)
                LOGGER.info('Extracting bundle {0} into {1}: complete'.format(filename, bundle_path))

                LOGGER.info('Dropping: begin')
#                completed_process = subprocess.run('cd {0} && [ -s ./requirements_conda.txt ] && conda install --yes --file \
 #                                              ./requirements_conda.txt'.format(bundle_path),
 #                                              timeout=1200,
 #                                              shell=True,
 #                                              stdout=subprocess.PIPE)
 #               completed_process = subprocess.run('cd {0} && [ -s ./requirements.txt ] && pip install -r \
 #                                              ./requirements.txt'.format(bundle_path),
 #                                              timeout=1200,
 #                                              shell=True,
 #                                              stdout=subprocess.PIPE)
                LOGGER.info('Dropping: complete')

                LOGGER.info('"{0}" successfully deployed!'.format(model_key))
                self.write('"{0}" successfully deployed!'.format(model_key))
            except Exception as e:
                message = 'DropPython3Handler.post: Exception - {0} Error {1}'.format(model_key, str(e))
                LOGGER.info(message)
                logging.exception(message)


def main():
    try:
        tornado.options.parse_command_line()
        if not options.PIPELINE_DROP_SERVER_PORT or not options.PIPELINE_DROP_PATH:
            LOGGER.error('--PIPELINE_DROP_SERVER_PORT and --PIPELINE_DROP_PATH must be set')
            return

        LOGGER.info('Drop Server main: begin start tornado-based http server port {0}'.format(options.PIPELINE_DROP_SERVER_PORT))
        http_server = tornado.httpserver.HTTPServer(Application())
        http_server.listen(options.PIPELINE_DROP_SERVER_PORT)
        LOGGER.info('Drop Server main: complete start tornado-based http server port {0}'.format(options.PIPELINE_DROP_SERVER_PORT))

        tornado.ioloop.IOLoop.current().start()
        print('...Python-based Drop Server Started!')
    except Exception as e:
        LOGGER.info('drop_server_python.main: Exception {0}'.format(str(e)))
        logging.exception('drop_server_python.main: Exception {0}'.format(str(e)))


if __name__ == '__main__':
    main()

