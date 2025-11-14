import { Router } from 'express';
import externalRoutes from './externalRoutes';
import internalRoutes from './internalRoutes';

const router = Router();

// External routes are public and do not require authentication
// Resulting URL: /api/v1/external/...
router.use('/external', externalRoutes);

// Internal routes require authentication and are for authenticated users
// Resulting URL: /api/v1/internal/...
router.use('/internal', internalRoutes);

export default router;
