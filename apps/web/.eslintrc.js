module.exports = {
  extends: ['../../packages/config/eslint-config', 'next/core-web-vitals'],
  plugins: ['react'],
  globals: {
    React: 'readonly',
  },
  rules: {
    'react/react-in-jsx-scope': 'off',
  },
};