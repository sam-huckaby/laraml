/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./bin/main.ml", "./lib/**/*.ml", "./www/**/*.js", "./scripts/**/*.js"],
  theme: {
    extend: {
    colors: {
      whnvr: {
        50: "#f2f7f9",
        100: "#deeaef",
        200: "#c0d5e1",
        300: "#95b9cb",
        400: "#6293ae",
        500: "#477793",
        600: "#3e627c",
        700: "#375267",
        800: "#334657",
        900: "#27333f",
        950: "#1b2631",
      }
    },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ]
}

