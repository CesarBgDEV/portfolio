import { es } from './es';
import { en } from './en';

export type Lang = 'es' | 'en';

const translations = { es, en };

export function getLangFromUrl(url: URL): Lang {
  const [, lang] = url.pathname.split('/');
  if (lang === 'en') return 'en';
  return 'es';
}

export function useTranslations(lang: Lang) {
  return function t(key: string): string {
    const dict = translations[lang] as Record<string, string>;
    return dict[key] ?? key;
  };
}

export function getAlternateUrl(url: URL): string {
  const currentLang = getLangFromUrl(url);
  const targetLang: Lang = currentLang === 'es' ? 'en' : 'es';
  const pathWithoutLang = url.pathname.replace(/^\/(es|en)/, '');
  return `/${targetLang}${pathWithoutLang || '/'}`;
}
