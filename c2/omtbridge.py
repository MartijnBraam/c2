"""Spawns omt-camera-bridge as a subprocess and hands it raw camera frames
over its stdin - the same shape as picamera2's own FfmpegOutput spawning
ffmpeg. Only the newest frame is kept - a slow or dead child never stalls
the camera capture thread. If the child dies it's respawned, mirroring the
`Restart=on-failure` / `RestartSec=1` this used to get from systemd.
"""

import subprocess
import threading
import time


class OmtBridge:
    RESTART_DELAY = 1.0

    def __init__(self, binary, name, width, height, fps):
        self._cmd = [
            binary,
            "--name", name,
            "--width", str(width),
            "--height", str(height),
            "--fps", str(fps),
        ]

        self._latest = None
        self._cond = threading.Condition()
        self._proc = None
        self._proc_lock = threading.Lock()

        self._spawn()
        threading.Thread(target=self._send_loop, daemon=True, name="omt-bridge-send").start()

    def _spawn(self):
        proc = subprocess.Popen(self._cmd, stdin=subprocess.PIPE)
        with self._proc_lock:
            self._proc = proc

    def is_running(self):
        with self._proc_lock:
            return self._proc is not None and self._proc.poll() is None

    def wants_frame(self):
        """False while the previous frame is still queued/being sent - lets
        the caller skip capturing a new one instead of computing work that
        would just be dropped."""
        with self._cond:
            return self._latest is None

    def push_frame(self, data):
        with self._cond:
            self._latest = data
            self._cond.notify()

    def _send_loop(self):
        while True:
            with self._cond:
                while self._latest is None:
                    self._cond.wait()
                data = self._latest
                self._latest = None

            with self._proc_lock:
                proc = self._proc
            if proc.poll() is not None:
                time.sleep(self.RESTART_DELAY)
                self._spawn()
                continue

            try:
                proc.stdin.write(data)
            except (BrokenPipeError, OSError):
                proc.wait()
                time.sleep(self.RESTART_DELAY)
                self._spawn()
