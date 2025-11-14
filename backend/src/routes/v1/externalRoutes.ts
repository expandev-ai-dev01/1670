import { Router } from 'express';
import { loginHandler } from '@/api/v1/external/security/login/controller';

const router = Router();

// Authentication routes
const securityRouter = Router();
securityRouter.post('/login', loginHandler);

router.use('/security', securityRouter);

export default router;
