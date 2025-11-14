import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { dbRequest, ExpectedReturn } from '@/utils/database/db';
import { config } from '@/config';
import { LoginInput, LoginResponse, UserPayload } from './authTypes';

const LOCKOUT_MINUTES = 15;

/**
 * @summary
 * Authenticates a user based on email and password.
 *
 * @param {LoginInput} credentials The user's login credentials.
 * @param {string} ipAddress The IP address of the user.
 * @param {string} userAgent The user agent of the client.
 * @returns {Promise<LoginResponse>} A promise that resolves with the JWT and user info.
 * @throws {Error} If authentication fails for any reason (user not found, wrong password, account locked).
 */
export async function login(
  credentials: LoginInput,
  ipAddress: string,
  userAgent: string
): Promise<LoginResponse> {
  const { email, password, rememberMe } = credentials;

  const user = await dbRequest(
    '[security].[spUserAccountGetByEmail]',
    { email },
    ExpectedReturn.Single
  );

  if (!user || !user.active) {
    await dbRequest(
      '[security].[spLoginFailure]',
      { emailAttempt: email, ipAddress, userAgent },
      ExpectedReturn.None
    );
    throw new Error('invalidCredentials');
  }

  if (user.lockedUntil && new Date(user.lockedUntil) > new Date()) {
    const minutesRemaining = Math.ceil(
      (new Date(user.lockedUntil).getTime() - new Date().getTime()) / 60000
    );
    throw new Error(`accountLocked:${minutesRemaining || 1}`);
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

  if (!isPasswordValid) {
    await dbRequest(
      '[security].[spLoginFailure]',
      { emailAttempt: email, ipAddress, userAgent },
      ExpectedReturn.None
    );
    const attemptsLeft = 4 - user.failedLoginAttempts;
    if (attemptsLeft <= 0) {
      throw new Error(`accountLocked:${LOCKOUT_MINUTES}`);
    }
    throw new Error(`invalidCredentials`);
  }

  const userPayload: UserPayload = {
    idUserAccount: user.idUserAccount,
    name: user.name,
    email: user.email,
  };

  const expiresIn = rememberMe ? config.jwt.rememberMeExpiresIn : config.jwt.expiresIn;
  const token = jwt.sign(userPayload, config.jwt.secret, { expiresIn });

  const expiresAt = new Date();
  const durationSeconds = rememberMe ? 30 * 24 * 60 * 60 : 2 * 60 * 60; // 30 days or 2 hours
  expiresAt.setSeconds(expiresAt.getSeconds() + durationSeconds);

  await dbRequest(
    '[security].[spLoginSuccess]',
    {
      idUserAccount: user.idUserAccount,
      ipAddress,
      userAgent,
      token,
      expiresAt,
    },
    ExpectedReturn.None
  );

  return {
    token,
    user: userPayload,
  };
}
