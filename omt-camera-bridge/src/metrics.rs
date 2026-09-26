//! Per-frame timing telemetry, emitted via `tracing` - kept separate from
//! the video pipeline logic in `main`.

use std::time::{Duration, Instant};

/// Times a closure, returning its result and elapsed duration - decoupled
/// from what it's timing.
fn time<T>(f: impl FnOnce() -> T) -> (T, Duration) {
    let start = Instant::now();
    let result = f();
    (result, start.elapsed())
}

/// Accumulates per-frame send timings and periodically reports the average
/// time/frame and achieved frames/sec. `main` only calls `time_send`/
/// `record_frame`/`maybe_report` and never touches a `Duration` directly.
pub struct Metrics {
    send: Duration,
    frames: u64,
    window_start: Instant,
    report_every: Duration,
}

impl Metrics {
    pub fn new(report_every: Duration) -> Self {
        Self {
            send: Duration::ZERO,
            frames: 0,
            window_start: Instant::now(),
            report_every,
        }
    }

    pub fn time_send<T>(&mut self, f: impl FnOnce() -> T) -> T {
        let (result, elapsed) = time(f);
        self.send += elapsed;
        result
    }

    pub fn record_frame(&mut self) {
        self.frames += 1;
    }

    /// Emits the window's average ms/frame and achieved fps as a tracing
    /// event, then resets it - a no-op until `report_every` has elapsed.
    pub fn maybe_report(&mut self) {
        let elapsed = self.window_start.elapsed();
        if elapsed < self.report_every {
            return;
        }

        let avg_ms = self.send.as_secs_f64() * 1000.0 / self.frames.max(1) as f64;
        let fps = self.frames as f64 / elapsed.as_secs_f64();

        // Pre-formatted to &str - tracing-journald falls back to full-precision
        // Debug output for raw f64 fields.
        let avg_ms = format!("{avg_ms:.3}");
        let fps = format!("{fps:.2}");

        tracing::info!(
            omt_avg_ms = avg_ms.as_str(),
            omt_fps = fps.as_str(),
            omt_frame_count = self.frames,
            "omt-camera-bridge: {avg_ms}ms/frame avg, {fps} fps over {} frames",
            self.frames,
        );

        *self = Self::new(self.report_every);
    }
}
