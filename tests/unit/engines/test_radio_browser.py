# SPDX-License-Identifier: AGPL-3.0-or-later
# pylint: disable=missing-module-docstring,invalid-name

import socket
from unittest import mock

from searx.engines import radio_browser
from tests import SearxTestCase


class _CacheStub:
    def __init__(self):
        self._store = {}

    def get(self, key, default=None):
        return self._store.get(key, default)

    def set(self, key, value, expire=None):
        self._store[key] = value


class TestRadioBrowser(SearxTestCase):

    def setUp(self):
        super().setUp()
        radio_browser.CACHE = _CacheStub()

    def test_server_list_fallback_when_reverse_dns_fails(self):
        with mock.patch.object(
            socket,
            "getaddrinfo",
            return_value=[(None, None, None, None, ("1.1.1.1", 80))],
        ), mock.patch.object(socket, "gethostbyaddr", side_effect=socket.herror(11004, "host not found")):
            servers = radio_browser.server_list()

        self.assertEqual(servers, ["https://all.api.radio-browser.info"])

    def test_server_list_collects_resolved_servers(self):
        with mock.patch.object(
            socket,
            "getaddrinfo",
            return_value=[(None, None, None, None, ("45.80.1.120", 80))],
        ), mock.patch.object(
            socket,
            "gethostbyaddr",
            return_value=("de1.api.radio-browser.info", [], ["45.80.1.120"]),
        ):
            servers = radio_browser.server_list()

        self.assertEqual(servers, ["https://de1.api.radio-browser.info"])
