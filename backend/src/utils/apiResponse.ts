export interface SuccessResponse<T> {
  success: true;
  data: T;
  metadata?: {
    timestamp: string;
    [key: string]: any;
  };
}

export interface ErrorResponse {
  success: false;
  error: {
    code: number | string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

export const successResponse = <T>(
  data: T,
  metadata?: Record<string, any>
): SuccessResponse<T> => ({
  success: true,
  data,
  metadata: {
    ...metadata,
    timestamp: new Date().toISOString(),
  },
});

export const errorResponse = (
  code: number | string,
  message: string,
  details?: any
): ErrorResponse => ({
  success: false,
  error: {
    code,
    message,
    details,
  },
  timestamp: new Date().toISOString(),
});
