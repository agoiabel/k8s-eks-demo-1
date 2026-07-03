const request = require('supertest');
const { app } = require('./server');

// supertest binds the app to a random available port internally
// for each request, then releases it. No port 3000 involved at all.
// No afterAll needed — nothing real was opened.

describe('GET /', () => {
  test('returns 200 with expected shape', async () => {
    const res = await request(app).get('/');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('message');
    expect(res.body).toHaveProperty('version');
    expect(res.body).toHaveProperty('pod');
    expect(res.body).toHaveProperty('timestamp');
  });

  test('returns default values when env vars are not set', async () => {
    const res = await request(app).get('/');

    expect(res.body.version).toBe('unknown');
    expect(res.body.message).toBe('Hello from Node.js!');
  });
});

describe('GET /healthz', () => {
  test('returns 200 with status ok', async () => {
    const res = await request(app).get('/healthz');

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});