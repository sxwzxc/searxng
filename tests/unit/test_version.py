# SPDX-License-Identifier: AGPL-3.0-or-later
# pylint: disable=missing-module-docstring,invalid-name

import subprocess
from unittest import mock

from searx import version
from tests import SearxTestCase


class TestVersion(SearxTestCase):

    def test_get_git_version_fallback_to_short_date(self):
        def fake_subprocess_run(args, **kwargs):
            if isinstance(args, list) and "--date=format:%Y.%m.%d" in args:
                raise subprocess.CalledProcessError(128, args, stderr="fatal: unknown date format 'format:%Y.%m.%d'")
            if isinstance(args, list) and "--date=short" in args:
                return "2026-02-05+abcdef1"
            if isinstance(args, list) and len(args) >= 3 and args[:3] == ["git", "diff", "--quiet"]:
                return ""
            raise AssertionError(f"unexpected command: {args}")

        with mock.patch.object(version, "subprocess_run", side_effect=fake_subprocess_run):
            git_version, tag_version, docker_tag = version.get_git_version()

        self.assertEqual(git_version, "2026.2.5+abcdef1")
        self.assertEqual(tag_version, "2026.2.5+abcdef1")
        self.assertEqual(docker_tag, "2026.2.5-abcdef1")

    def test_get_git_version_dirty_suffix(self):
        def fake_subprocess_run(args, **kwargs):
            if isinstance(args, list) and "--date=format:%Y.%m.%d" in args:
                return "2026.2.5+abcdef1"
            if isinstance(args, list) and len(args) >= 3 and args[:3] == ["git", "diff", "--quiet"]:
                raise subprocess.CalledProcessError(1, args)
            raise AssertionError(f"unexpected command: {args}")

        with mock.patch.object(version, "subprocess_run", side_effect=fake_subprocess_run):
            git_version, tag_version, docker_tag = version.get_git_version()

        self.assertEqual(git_version, "2026.2.5+abcdef1+dirty")
        self.assertEqual(tag_version, "2026.2.5+abcdef1")
        self.assertEqual(docker_tag, "2026.2.5-abcdef1")
