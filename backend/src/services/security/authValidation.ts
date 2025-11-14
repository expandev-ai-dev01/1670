import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('invalidEmailFormat').max(255),
  password: z.string().min(1, 'passwordIsRequired'),
  rememberMe: z.boolean().optional().default(false),
});
