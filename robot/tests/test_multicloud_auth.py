import base64
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import unittest
import xml.etree.ElementTree as ET
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


ROOT = Path(__file__).resolve().parents[2]
RESOURCE = ROOT / "robot/resources/multicloud_interface.robot"
USERNAME = "multicloud-user-sentinel"
PASSWORD = "multicloud-password-sentinel"


class RequestRecorder(BaseHTTPRequestHandler):
    def do_GET(self):
        self.server.requests.append((self.path, self.headers.get("Authorization")))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, format_string, *args):
        pass


class MultiCloudAuthTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), RequestRecorder)
        cls.server.requests = []
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def run_probe(self, endpoints, credentials=None, globals_credentials=None,
                  succeeds=True):
        self.server.requests.clear()
        environment = dict(os.environ)
        for name in ("MULTICLOUD_AUTH_USERNAME", "MULTICLOUD_AUTH_PASSWORD",
                     "TEST_GLOBAL_MC_AUTH_USERNAME", "TEST_GLOBAL_MC_AUTH_PASSWORD"):
            environment.pop(name, None)
        environment.update(credentials or {})
        environment.update({"TEST_" + name: value
                            for name, value in (globals_credentials or {}).items()})
        environment["NO_PROXY"] = "127.0.0.1"
        environment["no_proxy"] = "127.0.0.1"
        address = "http://127.0.0.1:%s" % self.server.server_port
        variables = {
            "GLOBAL_SDC_SERVER_PROTOCOL": "http",
            "GLOBAL_INJECTED_SDC_DCAE_BE_IP_ADDR": "127.0.0.1",
            "GLOBAL_SDC_DCAE_BE_PORT": "1",
        }
        for provider in ("MC", "MC_PIKE", "MC_PROMETHEUS", "MC_STARLINGX",
                         "MC_TC", "MC_VIO", "MC_K8S", "MC_FCAPS"):
            variables["GLOBAL_%s_SERVER_PROTOCOL" % provider] = "http"
            variables["GLOBAL_INJECTED_%s_IP_ADDR" % provider] = "127.0.0.1"
            variables["GLOBAL_%s_SERVER_PORT" % provider] = "1"
            variables[provider + "_ENDPOINT"] = address + "/" + provider.lower()
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            variable_file = directory / "variables.py"
            variable_file.write_text(
                "import os\n"
                "def get_variables():\n"
                "    values = %r\n"
                "    values.update({name[5:]: value for name, value in os.environ.items()\n"
                "                   if name.startswith('TEST_GLOBAL_MC_AUTH_')})\n"
                "    return values\n" % variables,
                encoding="utf-8",
            )
            suite = directory / "probe.robot"
            suite.write_text(
                "*** Settings ***\nResource    %s\n"
                "*** Test Cases ***\nProbe\n"
                "    [Teardown]    Log    Logging restored after request\n" % RESOURCE
                + "".join("    Run MultiCloud Get Request    ${%s_ENDPOINT}    /probe\n"
                          % endpoint for endpoint in endpoints),
                encoding="utf-8",
            )
            result = subprocess.run(
                [sys.executable, "-m", "robot", "--loglevel", "TRACE",
                 "--variablefile", str(variable_file), "--outputdir", str(directory),
                 str(suite)],
                env=environment, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, timeout=30,
            )
            output = ET.parse(directory / "output.xml")
            messages = "\n".join(output.getroot().itertext())
            logged_messages = [message.text for message in output.findall(".//msg")]
            self.assertIn("Logging restored after request", logged_messages)
            artifacts = [result.stdout, messages]
            artifacts.extend((directory / name).read_text(encoding="utf-8")
                             for name in ("output.xml", "log.html", "report.html"))
            combined = "\n".join(artifacts)
            secrets = list((credentials or {}).values())
            secrets.extend((globals_credentials or {}).values())
            for secret in secrets:
                if secret.strip():
                    self.assertFalse(secret in combined, "Credential leaked into Robot reports")
            pairs = [(credentials or {}, "MULTICLOUD_AUTH_"),
                     (globals_credentials or {}, "GLOBAL_MC_AUTH_")]
            for values, prefix in pairs:
                if prefix + "USERNAME" in values and prefix + "PASSWORD" in values:
                    encoded = base64.b64encode(
                        (values[prefix + "USERNAME"] + ":"
                         + values[prefix + "PASSWORD"]).encode("latin-1")
                    ).decode("ascii")
                    self.assertNotIn(encoded, combined, "Basic header leaked into Robot reports")
            if succeeds:
                self.assertEqual(0, result.returncode, result.stdout)
            else:
                self.assertEqual(1, result.returncode, result.stdout)
                self.assertTrue(output.find(".//test/status").text.startswith(
                    "MultiCloud authentication"), result.stdout)
                self.assertEqual([], self.server.requests)
        return list(self.server.requests)

    def test_default_requests_are_anonymous(self):
        requests = self.run_probe(["MC", "MC_K8S", "MC_PIKE", "MC_PROMETHEUS"])
        self.assertEqual([None] * 4, [auth for path, auth in requests])

    def test_environment_credentials_authenticate_only_broker_and_k8s(self):
        requests = self.run_probe(
            ["MC", "MC_K8S", "MC_PIKE", "MC_PROMETHEUS", "MC_STARLINGX",
             "MC_TC", "MC_VIO", "MC_FCAPS", "MC"],
            {"MULTICLOUD_AUTH_USERNAME": USERNAME, "MULTICLOUD_AUTH_PASSWORD": PASSWORD},
        )
        expected = "Basic " + base64.b64encode(
            (USERNAME + ":" + PASSWORD).encode("ascii")).decode("ascii")
        self.assertEqual([expected, expected] + [None] * 6 + [expected],
                         [auth for path, auth in requests])

    def test_globals_are_supported_without_environment_credentials(self):
        requests = self.run_probe(
            ["MC", "MC_K8S"], globals_credentials={
                "GLOBAL_MC_AUTH_USERNAME": USERNAME, "GLOBAL_MC_AUTH_PASSWORD": PASSWORD},
        )
        expected = "Basic " + base64.b64encode(
            (USERNAME + ":" + PASSWORD).encode("ascii")).decode("ascii")
        self.assertEqual([expected, expected], [auth for path, auth in requests])

    def test_environment_takes_precedence_over_globals(self):
        requests = self.run_probe(
            ["MC"], {"MULTICLOUD_AUTH_USERNAME": USERNAME,
                     "MULTICLOUD_AUTH_PASSWORD": PASSWORD},
            {"GLOBAL_MC_AUTH_USERNAME": "unused-user-sentinel",
             "GLOBAL_MC_AUTH_PASSWORD": "unused-password-sentinel"},
        )
        expected = "Basic " + base64.b64encode(
            (USERNAME + ":" + PASSWORD).encode("ascii")).decode("ascii")
        self.assertEqual(expected, requests[0][1])

    def test_partial_environment_cannot_be_completed_from_globals(self):
        self.run_probe(
            ["MC"], {"MULTICLOUD_AUTH_USERNAME": USERNAME},
            {"GLOBAL_MC_AUTH_USERNAME": "unused-user-sentinel",
             "GLOBAL_MC_AUTH_PASSWORD": "unused-password-sentinel"}, succeeds=False,
        )

    def test_partial_and_invalid_credentials_fail_without_request_or_secret_logs(self):
        cases = [
            {"MULTICLOUD_AUTH_USERNAME": USERNAME},
            {"MULTICLOUD_AUTH_PASSWORD": PASSWORD},
            {"MULTICLOUD_AUTH_USERNAME": "", "MULTICLOUD_AUTH_PASSWORD": ""},
            {"MULTICLOUD_AUTH_USERNAME": "", "MULTICLOUD_AUTH_PASSWORD": PASSWORD},
            {"MULTICLOUD_AUTH_USERNAME": USERNAME, "MULTICLOUD_AUTH_PASSWORD": ""},
            {"MULTICLOUD_AUTH_USERNAME": " \t", "MULTICLOUD_AUTH_PASSWORD": PASSWORD},
            {"MULTICLOUD_AUTH_USERNAME": USERNAME, "MULTICLOUD_AUTH_PASSWORD": " \t"},
            {"MULTICLOUD_AUTH_USERNAME": "invalid:user-sentinel",
             "MULTICLOUD_AUTH_PASSWORD": PASSWORD},
        ]
        for index, credentials in enumerate(cases):
            with self.subTest(case=index):
                self.run_probe(["MC"], credentials, succeeds=False)

    def test_invalid_globals_fail_redacted(self):
        for index, values in enumerate((
                {"GLOBAL_MC_AUTH_PASSWORD": PASSWORD},
                {"GLOBAL_MC_AUTH_USERNAME": "invalid:global-sentinel",
                 "GLOBAL_MC_AUTH_PASSWORD": PASSWORD})):
            with self.subTest(case=index):
                self.run_probe(["MC_K8S"], globals_credentials=values, succeeds=False)

    def test_unrelated_endpoints_do_not_read_invalid_authentication(self):
        requests = self.run_probe(
            ["MC_PIKE", "MC_PROMETHEUS"], {"MULTICLOUD_AUTH_PASSWORD": PASSWORD})
        self.assertEqual([None, None], [auth for path, auth in requests])

    def test_credentials_remain_literal_and_reports_remain_redacted(self):
        username = " literal-'\"\\${opaque}-user "
        password = " literal-'\"\\${opaque}:$@{items}:__import__('os')-secret "
        expected = "Basic " + base64.b64encode(
            (username + ":" + password).encode("ascii")).decode("ascii")
        for source in ("environment", "globals"):
            with self.subTest(source=source):
                arguments = {"credentials": {"MULTICLOUD_AUTH_USERNAME": username,
                                             "MULTICLOUD_AUTH_PASSWORD": password}}
                if source == "globals":
                    arguments = {"globals_credentials": {
                        "GLOBAL_MC_AUTH_USERNAME": username,
                        "GLOBAL_MC_AUTH_PASSWORD": password}}
                requests = self.run_probe(["MC", "MC_K8S"], **arguments)
                self.assertEqual([expected, expected], [auth for path, auth in requests])


if __name__ == "__main__":
    unittest.main()