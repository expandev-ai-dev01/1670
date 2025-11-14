import { z } from 'zod';
import { loginSchema } from './authValidation';

export type LoginInput = z.infer<typeof loginSchema>;

export interface UserPayload {
  idUserAccount: number;
  name: string;
  email: string;
}

export interface LoginResponse {
  token: string;
  user: UserPayload;
}
