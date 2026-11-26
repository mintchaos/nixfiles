"""Smoke-test the real review server, optionally through `nix run`.

Usage: python3 tests/review.py /absolute/path/to/plannotator
   or: python3 tests/review.py nix run /absolute/path/to/flake --
"""

import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request


def main():
    command = sys.argv[1:]
    if not command:
        raise SystemExit("Supply a binary or nix run command")

    with tempfile.TemporaryDirectory(prefix="plannotator-review-") as temporary:
        root = Path(temporary)
        home = root / "home"
        repository = root / "repo"
        home.mkdir()
        repository.mkdir()
        env = {
            **os.environ,
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(home / ".config"),
            "XDG_DATA_HOME": str(home / ".local/share"),
            "XDG_CACHE_HOME": str(home / ".cache"),
            "PLANNOTATOR_DATA_DIR": str(home / "data"),
            "PLANNOTATOR_BROWSER": "none",
            "PLANNOTATOR_UPDATE_CHECK": "0",
            "PLANNOTATOR_AUTO_UPDATE": "0",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": "/dev/null",
        }
        for args in [
            ["init", "--quiet"],
            ["config", "user.name", "Plannotator smoke test"],
            ["config", "user.email", "test@example.invalid"],
        ]:
            subprocess.run(["git", *args], cwd=repository, env=env, check=True)
        document = repository / "example.txt"
        document.write_text("before\n")
        subprocess.run(["git", "add", "."], cwd=repository, env=env, check=True)
        subprocess.run(
            ["git", "commit", "--quiet", "-m", "fixture"],
            cwd=repository,
            env=env,
            check=True,
        )
        document.write_text("after\n")
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", 0))
            env["PLANNOTATOR_PORT"] = str(listener.getsockname()[1])

        with (root / "server.log").open("w+") as log:
            process = subprocess.Popen(
                [*command, "review"],
                cwd=repository,
                env=env,
                stdout=log,
                stderr=log,
                start_new_session=True,
            )
            try:
                deadline = time.monotonic() + 60
                while time.monotonic() < deadline:
                    if process.poll() is not None:
                        raise AssertionError(f"review exited with {process.returncode}")
                    try:
                        url = f"http://127.0.0.1:{env['PLANNOTATOR_PORT']}/api/diff"
                        with urllib.request.urlopen(url, timeout=1) as response:
                            payload = json.load(response)
                        # A live page alone is insufficient: git must work too.
                        assert "example.txt" in json.dumps(payload), payload
                        assert "after" in json.dumps(payload), payload
                        assert not (home / ".local/bin/plannotator").exists()
                        print("PASS: review serves the fixture diff over HTTP")
                        break
                    except (urllib.error.URLError, TimeoutError):
                        time.sleep(0.1)
                else:
                    raise AssertionError("review server did not become ready within 60s")
            except BaseException:
                log.seek(0)
                print(log.read(), file=sys.stderr)
                raise
            finally:
                try:
                    os.killpg(process.pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()


if __name__ == "__main__":
    main()
