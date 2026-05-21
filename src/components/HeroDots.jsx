import { useEffect, useRef } from 'react';

const SPACING   = 28;
const BASE_R    = 1.4;
const GLOW_R    = 160;
const LERP      = 0.07;

function isDarkTheme() {
  return document.documentElement.dataset.theme !== 'light';
}

export default function HeroDots() {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // The hero <section> is the actual parent we need for events and sizing
    const hero = canvas.closest('.hero') || canvas.parentElement.parentElement;
    const ctx  = canvas.getContext('2d');

    let raf;
    let tx = -9999, ty = -9999;   // target (raw mouse)
    let mx = -9999, my = -9999;   // smoothed

    /* ── size canvas to match the hero section ── */
    function resize() {
      const { width, height } = hero.getBoundingClientRect();
      canvas.width  = Math.round(width);
      canvas.height = Math.round(height);
    }

    /* ── draw ── */
    function draw() {
      const W = canvas.width;
      const H = canvas.height;
      if (!W || !H) { raf = requestAnimationFrame(draw); return; }

      ctx.clearRect(0, 0, W, H);

      // lerp towards target
      mx += (tx - mx) * LERP;
      my += (ty - my) * LERP;

      const dark      = isDarkTheme();
      const baseAlpha = dark ? 0.13 : 0.09;
      const [r, g, b] = dark ? [64, 150, 255] : [37, 99, 235];

      const cols = Math.ceil(W / SPACING) + 1;
      const rows = Math.ceil(H / SPACING) + 1;

      for (let c = 0; c < cols; c++) {
        for (let row = 0; row < rows; row++) {
          const x = c * SPACING;
          const y = row * SPACING;

          const dist = Math.hypot(x - mx, y - my);
          const raw  = Math.max(0, 1 - dist / GLOW_R);
          const t    = raw * raw;    // quadratic ease

          const alpha  = t > 0.01 ? baseAlpha + t * (dark ? 0.72 : 0.58) : baseAlpha;
          const radius = BASE_R + t * 2.4;

          ctx.beginPath();
          ctx.arc(x, y, radius, 0, Math.PI * 2);
          ctx.fillStyle = `rgba(${r},${g},${b},${alpha.toFixed(3)})`;
          ctx.fill();
        }
      }

      raf = requestAnimationFrame(draw);
    }

    /* ── mouse events on the HERO SECTION, not the island wrapper ── */
    function onMove(e) {
      const rect = hero.getBoundingClientRect();
      tx = e.clientX - rect.left;
      ty = e.clientY - rect.top;
    }
    function onLeave() {
      tx = -9999;
      ty = -9999;
    }

    hero.addEventListener('mousemove', onMove);
    hero.addEventListener('mouseleave', onLeave);
    window.addEventListener('resize', resize);

    resize();
    draw();

    return () => {
      cancelAnimationFrame(raf);
      hero.removeEventListener('mousemove', onMove);
      hero.removeEventListener('mouseleave', onLeave);
      window.removeEventListener('resize', resize);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      style={{
        position: 'absolute',
        inset: 0,
        width: '100%',
        height: '100%',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  );
}
