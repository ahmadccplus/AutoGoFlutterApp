import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  userId?: number;
  userRole?: string;
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({
      success: false,
      message: 'Access token required',
    });
    return;
  }

  // Use the same secret as AuthService
  const jwtSecret = process.env.JWT_SECRET || 'autogo_jwt_secret_key_for_development_only_change_in_production';
  if (!jwtSecret) {
    res.status(500).json({
      success: false,
      message: 'Server configuration error',
    });
    return;
  }

  jwt.verify(token, jwtSecret, (err: any, decoded: any) => {
    if (err) {
      res.status(403).json({
        success: false,
        message: 'Invalid or expired token',
      });
      return;
    }

    req.userId = decoded.userId;
    req.userRole = decoded.role;
    next();
  });
};

export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.userRole || !roles.includes(req.userRole)) {
      res.status(403).json({
        success: false,
        message: 'Insufficient permissions',
      });
      return;
    }
    next();
  };
};



