import { useState, useEffect } from 'react';

const FIRST  = 'César Balderas';
const SECOND = 'Guillén';
const TOTAL  = FIRST.length + SECOND.length;

export default function TypewriterName({ speed = 68 }) {
  const [idx, setIdx] = useState(0);
  const [cursorOn, setCursorOn] = useState(true);

  // typing — random jitter makes it feel natural
  useEffect(() => {
    if (idx >= TOTAL) return;
    const t = setTimeout(() => setIdx(i => i + 1), speed + Math.random() * 28);
    return () => clearTimeout(t);
  }, [idx, speed]);

  // cursor blink
  useEffect(() => {
    const t = setInterval(() => setCursorOn(v => !v), 530);
    return () => clearInterval(t);
  }, []);

  const firstShown  = FIRST.slice(0, Math.min(idx, FIRST.length));
  const secondShown = idx > FIRST.length ? SECOND.slice(0, idx - FIRST.length) : '';
  const done        = idx >= TOTAL;

  return (
    <>
      {firstShown}
      {idx >= FIRST.length && <br />}
      {secondShown && <span>{secondShown}</span>}
      <span
        className="typewriter-cursor"
        aria-hidden="true"
        style={{ opacity: done ? 0 : (cursorOn ? 1 : 0) }}
      >
        |
      </span>
    </>
  );
}
