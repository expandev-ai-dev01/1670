import { Request, Response, NextFunction } from 'express';
import { loginSchema } from '@/services/security/authValidation';
import * as authService from '@/services/security/authService';
import { successResponse, errorResponse } from '@/utils/apiResponse';

/**
 * @api {post} /external/security/login User Login
 * @apiName UserLogin
 * @apiGroup Security
 * @apiVersion 1.0.0
 *
 * @apiDescription Authenticates a user and returns a JWT.
 *
 * @apiParam {String} email User's email address.
 * @apiParam {String} password User's password.
 * @apiParam {Boolean} [rememberMe] If true, the session will last longer.
 *
 * @apiSuccess {String} token The JSON Web Token for the session.
 * @apiSuccess {Object} user User's basic information.
 *
 * @apiError {String} InvalidCredentials Email or password is incorrect.
 * @apiError {String} AccountLocked The account is temporarily locked.
 */
export async function loginHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const validationResult = loginSchema.safeParse(req.body);
    if (!validationResult.success) {
      res.status(400).json(errorResponse(400, 'validationError', validationResult.error.issues));
      return;
    }

    const ipAddress = req.ip || 'unknown';
    const userAgent = req.headers['user-agent'] || 'unknown';

    const result = await authService.login(validationResult.data, ipAddress, userAgent);

    res.status(200).json(successResponse(result));
  } catch (error: any) {
    if (error.message.startsWith('accountLocked')) {
      const minutes = error.message.split(':')[1];
      res
        .status(403)
        .json(
          errorResponse(403, `Your account is temporarily locked. Try again in ${minutes} minutes.`)
        );
    } else if (error.message === 'invalidCredentials') {
      res.status(401).json(errorResponse(401, 'Invalid email or password.'));
    } else {
      next(error);
    }
  }
}
