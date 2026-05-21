import { useState, useEffect } from 'react';

const PHRASES = {
  es: [
    'Co-Fundador & CTO · Valion Digital Consulting',
    'Ingeniero de Software Full Stack',
    'Django · React · Docker · PostgreSQL',
    'Construyendo soluciones que importan',
  ],
  en: [
    'Co-Founder & CTO · Valion Digital Consulting',
    'Full Stack Software Engineer',
    'Django · React · Docker · PostgreSQL',
    'Building solutions that matter',
  ],
};

export default function TypewriterRole({ lang = 'es', typingSpeed = 55, deletingSpeed = 30, pauseTime = 2800 }) {
  const phrases = PHRASES[lang] || PHRASES.es;
  const [displayed, setDisplayed] = useState('');
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [cursorVisible, setCursorVisible] = useState(true);

  useEffect(() => {
    const blink = setInterval(() => setCursorVisible((v) => !v), 530);
    return () => clearInterval(blink);
  }, []);

  useEffect(() => {
    const current = phrases[phraseIndex];

    if (!isDeleting && displayed === current) {
      const t = setTimeout(() => setIsDeleting(true), pauseTime);
      return () => clearTimeout(t);
    }

    if (isDeleting && displayed === '') {
      setIsDeleting(false);
      setPhraseIndex((i) => (i + 1) % phrases.length);
      return;
    }

    const speed = isDeleting ? deletingSpeed : typingSpeed;
    const t = setTimeout(() => {
      setDisplayed(
        isDeleting
          ? current.slice(0, displayed.length - 1)
          : current.slice(0, displayed.length + 1)
      );
    }, speed);

    return () => clearTimeout(t);
  }, [displayed, isDeleting, phraseIndex, phrases, typingSpeed, deletingSpeed, pauseTime]);

  return (
    <span className="typewriter-wrap">
      <span className="typewriter-text">{displayed}</span>
      <span
        className="typewriter-cursor"
        aria-hidden="true"
        style={{ opacity: cursorVisible ? 1 : 0 }}
      >
        |
      </span>
    </span>
  );
}
