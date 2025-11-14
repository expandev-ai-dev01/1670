import { Router } from 'express';
import v1Routes from './v1';

const router = Router();

// All V1 routes will be prefixed with /v1
router.use('/v1', v1Routes);

// Future versions can be added here
// import v2Routes from './v2';
// router.use('/v2', v2Routes);

export default router;
