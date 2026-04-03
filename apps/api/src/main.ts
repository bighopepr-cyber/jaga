// Register path aliases for runtime
import 'tsconfig-paths/register';

import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { AppModule } from './app.module';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    cors: {
      origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
      credentials: process.env.CORS_CREDENTIALS === 'true',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      maxAge: 3600,
    },
  });

  // Security: Helmet protects against many vulnerabilities
  app.use(helmet());

  // Security: Rate limiting
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.',
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
    skip: (req) => {
      // Skip rate limiting for health check endpoints
      return req.path === '/health' || req.path === '/health/live';
    },
  });
  app.use('/api', limiter);

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({ transform: true, forbidNonWhitelisted: true }));

  // WebSocket adapter
  app.useWebSocketAdapter(new IoAdapter(app));

  // Set trust proxy for Docker/Kubernetes behind reverse proxies
  app.set('trust proxy', ['loopback', process.env.NGINX_IP || '172.20.0.0/16']);

  const port = process.env.API_PORT || 3001;
  const host = process.env.API_HOST || '0.0.0.0';
  
  await app.listen(port, host);

  console.log(`✅ API running on http://${host}:${port}`);
  console.log(`📡 WebSocket available at ws://${host}:${port}`);
  console.log(`🏥 Health check: http://${host}:${port}/health`);
}

bootstrap().catch((err) => {
  console.error('❌ Bootstrap error:', err);
  process.exit(1);
});
