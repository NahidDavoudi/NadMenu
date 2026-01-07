/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./assets/js/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        accent: 'var(--color-accent)',
        background: 'var(--color-bg)',
        text: 'var(--color-text)',
        card: 'var(--color-card-bg)',
      },
      fontFamily: {
        main: ['var(--font-main)'],
      },
      // Keep existing custom animations if useful, but ensure they use vars
    },
  },
  plugins: [],
}