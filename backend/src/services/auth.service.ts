import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserModel, User } from '../models/User';
import pool from '../config/database';

export class AuthService {
  private static readonly JWT_SECRET = process.env.JWT_SECRET || 'autogo_jwt_secret_key_for_development_only_change_in_production';
  private static readonly JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

  static generateToken(user: User): string {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
      },
      this.JWT_SECRET,
      { expiresIn: this.JWT_EXPIRES_IN } as jwt.SignOptions
    );
  }

  static async verifyToken(token: string): Promise<any> {
    return jwt.verify(token, this.JWT_SECRET);
  }

  static async loginWithGoogle(idToken: string): Promise<{ user: User; token: string }> {
    // In production, verify the Google ID token
    // For now, we'll create or find user by email from decoded token
    // This is a simplified version - you should verify the token with Google
    
    // Decode token (in production, verify with Google)
    const decoded: any = jwt.decode(idToken);
    if (!decoded || !decoded.email) {
      throw new Error('Invalid Google token');
    }

    let user = await UserModel.findByEmail(decoded.email);
    
    if (!user) {
      user = await UserModel.create({
        name: decoded.name || decoded.email.split('@')[0],
        email: decoded.email,
        role: 'renter',
      });
    }

    const token = this.generateToken(user);
    return { user, token };
  }

  static async loginWithFacebook(accessToken: string): Promise<{ user: User; token: string }> {
    // In production, verify the Facebook access token
    // This is a simplified version
    
    // For now, throw error - implement Facebook verification
    throw new Error('Facebook login not yet implemented');
  }

  static async sendOTP(phone: string): Promise<{ success: boolean; message: string }> {
    // In production, integrate with Twilio or similar service
    // For now, return success
    return {
      success: true,
      message: 'OTP sent successfully (use 123456 for testing)',
    };
  }

  static async verifyOTP(phone: string, otp: string): Promise<{ user: User; token: string }> {
    // In production, verify OTP with Twilio
    // For testing, accept 123456
    if (otp !== '123456') {
      throw new Error('Invalid OTP');
    }

    try {
      // Find or create user by phone
      const result = await pool.query(
        'SELECT * FROM users WHERE phone = $1',
        [phone]
      );

      let user: User;
      if (result.rows.length === 0) {
        user = await UserModel.create({
          name: `User ${phone}`,
          email: `${phone}@autogo.com`,
          phone,
          role: 'renter',
        });
      } else {
        user = result.rows[0];
      }

      const token = this.generateToken(user);
      return { user, token };
    } catch (dbError: any) {
      console.error('Database error in verifyOTP:', dbError);
      // If database is not available, create a mock user for testing
      const dbErrorCode = dbError.code || dbError.errno || '';
      const dbErrorMessage = dbError.message || '';
      
      if (dbErrorCode === 'ECONNREFUSED' || 
          dbErrorCode === '42P01' || 
          dbErrorCode === '3D000' ||
          dbErrorMessage.includes('does not exist') ||
          dbErrorMessage.includes('connection') ||
          dbErrorMessage.includes('timeout')) {
        console.warn('Database not available, using mock user for testing');
        const mockUser: User = {
          id: 1,
          name: `User ${phone}`,
          email: `${phone}@autogo.com`,
          phone,
          role: 'renter',
          is_verified: false,
          rating: 0,
          created_at: new Date(),
          updated_at: new Date(),
        };
        const token = this.generateToken(mockUser);
        return { user: mockUser, token };
      }
      throw dbError;
    }
  }
}



